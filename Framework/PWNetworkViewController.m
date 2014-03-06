//
//  PWNetworkViewController.m
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWNetworkViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WXManager.h"
#import "PWAppDelegate.h"
#import "PWReachability.h"

@interface PWNetworkViewController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;


@end

@implementation PWNetworkViewController

static const NSString *kezMobileURL =@"https://isjp7dbz.in.audi.vwg/kezmobile";
static const NSString *kezMobileHRURL = @"https://isjkpdbz.in.audi.vwg/kezmobile";
NSString *audiWLAN = @"platzerworld";

NetworkStatus lastNetworkStatus;
NetworkStatus currentNetworkStatus;
NSString* lastWifiSSID;
KEZNetworkStatus networkDirection;
PWReachability *myReachability;

- (id)init {
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"h a";
        
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"EEEE";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    myReachability = [[PWReachability alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeDismissed:) name:UIKeyboardWillHideNotification object:nil];
    /*
	self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIImage *background = [UIImage imageNamed:@"bg"];
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    CGFloat inset = 20;
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    CGRect hiloFrame = CGRectMake(inset, headerFrame.size.height - hiloHeight, headerFrame.size.width - 2*inset, hiloHeight);
    CGRect temperatureFrame = CGRectMake(inset, headerFrame.size.height - temperatureHeight - hiloHeight, headerFrame.size.width - 2*inset, temperatureHeight);
    CGRect iconFrame = CGRectMake(inset, temperatureFrame.origin.y - iconHeight, iconHeight, iconHeight);
    CGRect conditionsFrame = iconFrame;
    // make the conditions text a little smaller than the view
    // and to the right of our icon
    conditionsFrame.size.width = self.view.bounds.size.width - 2*inset - iconHeight - 10;
    conditionsFrame.origin.x = iconFrame.origin.x + iconHeight + 10;
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
	// bottom left
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    // top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview:conditionsLabel];
    
    // bottom left
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
    
    [[RACObserve([WXManager sharedManager], currentCondition)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WXCondition *newCondition) {
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         conditionsLabel.text = [newCondition.condition capitalizedString];
         cityLabel.text = [newCondition.locationName capitalizedString];
         
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       RACObserve([WXManager sharedManager], currentCondition.tempHigh),
                                                       RACObserve([WXManager sharedManager], currentCondition.tempLow)]
                                              reduce:^(NSNumber *hi, NSNumber *low) {
                                                  return [NSString  stringWithFormat:@"%.0f° / %.0f°",hi.floatValue,low.floatValue];
                                              }]
                            deliverOn:RACScheduler.mainThreadScheduler];
    
    [[RACObserve([WXManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[RACObserve([WXManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[WXManager sharedManager] findCurrentLocation];
     
     */
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
        return MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
    }
    return MIN([[WXManager sharedManager].dailyForecast count], 6) + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }
        else {
            WXCondition *weather = [WXManager sharedManager].hourlyForecast[indexPath.row - 1];
            [self configureHourlyCell:cell weather:weather];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else {
            WXCondition *weather = [WXManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather];
        }
    }
    
    return cell;
}

- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",weather.tempHigh.floatValue,weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    self.blurredImageView.alpha = percent;
}

- (IBAction)showMantle:(id)sender {
     NSLog(@"%s", __PRETTY_FUNCTION__);
    

    
}

- (IBAction)startNetworkNotification:(id)sender {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSLog(@"%s", __PRETTY_FUNCTION__);

    }
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cacheFilePath = [cachePath stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    if(![fileManager fileExistsAtPath:[cacheFilePath stringByAppendingPathComponent:@"nsurlcache"]]) {
        //create it, copy it from app bundle, download it etc.
        int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
        int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
        NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
        [NSURLCache setSharedURLCache:sharedCache];
        
    }

    // Set the application defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"NO" forKey:@"keyClearCache"];
    NSDictionary *appDefaultsKEZ = [NSDictionary dictionaryWithObject:@"YES" forKey:@"keyKEZmobilEnabled"];
    NSDictionary *appDefaultsHR = [NSDictionary dictionaryWithObject:@"YES" forKey:@"keyKEZmobilHREnabled"];
    NSDictionary *appDefaultsKEZPage = [NSDictionary dictionaryWithObject: kezMobileURL
                                                                   forKey:@"keyStartPageKEZ"];
    NSDictionary *appDefaultsHRPage = [NSDictionary dictionaryWithObject:kezMobileHRURL
                                                                  forKey:@"keyStartPageHR"];
    [defaults registerDefaults:appDefaults];
    [defaults registerDefaults:appDefaultsHR];
    [defaults registerDefaults:appDefaultsKEZ];
    [defaults registerDefaults:appDefaultsKEZPage];
    [defaults registerDefaults:appDefaultsHRPage];
    [defaults synchronize];
    
    [self clearCache];
   
}

-(void) clearCache {
    BOOL shouldClearCache  = [[NSUserDefaults standardUserDefaults] boolForKey:@"keyClearCache"];
    
    if (shouldClearCache) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        
        //change !!!!
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cacheFilePath = [cachePath stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
        if([fileManager fileExistsAtPath:[cacheFilePath stringByAppendingPathComponent:@"nsurlcache"]]) {
            
            [fileManager removeItemAtPath:[cacheFilePath stringByAppendingPathComponent:@"nsurlcache"] error:NULL];
            //create it, copy it from app bundle, download it etc.
            int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
            int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
            NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
            [NSURLCache setSharedURLCache:sharedCache];
            
        }
        
        
        
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"keyClearCache"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (IBAction)stopNetworkNotification:(id)sender {
    PWAppDelegate* appDel = (PWAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDel description];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendEmailToHelpDesk:) name:@"kSendMailHelpDesk" object:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"mailto"];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"kSendMailHelpDesk" object:urlString]];
}


#pragma mark - Keyboard notifications
// This method handles the animation of the view when the keyboard is displayed
- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
   
}

- (void)keyboardWillBeDismissed:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        NSValue *aValue = notification;
    }];
}

- (void) sendEmailToHelpDesk:(NSNotification*) notification {
    /*
    NSURL* url = notification.object;
    NSString *urlString = url.absoluteString;
    NSString *emailAddress = @"";
    NSString *subjectTitle = @"";
    NSString *bodyText = @"";
    
    
    NSArray* emailContent = [self parseURLString:urlString];
    emailAddress = [emailContent objectAtIndex:0];
    subjectTitle = [emailContent objectAtIndex:1];
    bodyText = [emailContent objectAtIndex:2];
    
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController * emailController = [[MFMailComposeViewController alloc] init];
        emailController.mailComposeDelegate = self;
        
        [emailController setSubject:subjectTitle];
        [emailController setMessageBody:bodyText isHTML:NO];
        [emailController setToRecipients:[NSArray arrayWithObject:emailAddress]];
        
        [self presentModalViewController:emailController animated:YES];
        
        // [emailController release];
    }
    
    else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You must have a mail account in order to send an email" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alertView show];
        // [alertView release];
    }
    */
}

-(NSArray *) parseURLString:(NSString *) urlString {
    
    // separate email address from subject and body
    NSArray *pathComponents = [urlString componentsSeparatedByString: @"?"];
    NSString *string2 = (NSString*) [pathComponents objectAtIndex:0];
    NSArray *mailComponents = [string2 componentsSeparatedByString: @":"];
    NSString *emailAddr = (NSString*) [mailComponents objectAtIndex:1];
    
    // separate subject from body
    NSArray *textComponents = [(NSString*) [pathComponents objectAtIndex:1] componentsSeparatedByString:@"&"];
    NSString *subject = @"";
    NSString *body = @"";
    NSString *safeTextString = @"";
    NSString *safeBodyString = @"";
    // is subject present -> decode it
    if (textComponents.count != 0) {
        subject = [textComponents objectAtIndex:0];
        NSArray *subjectComponents = [subject componentsSeparatedByString: @"="];
        NSString *subjectTitle = [subjectComponents objectAtIndex:1];
        safeTextString  = [subjectTitle stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
    }
    // if body present -> decode it
    if (textComponents.count >1) {
        body = [textComponents objectAtIndex:1];
        NSArray *bodyComponents = [body componentsSeparatedByString: @"="];
        NSString *bodyText = [bodyComponents objectAtIndex:1];
        
        //      NSString *parseBodyString = [[bodyText componentsSeparatedByString:@"%20"] componentsJoinedByString:@" "];
        NSString *parseBodyString = [[bodyText componentsSeparatedByString:@"%0A"] componentsJoinedByString:@"\n"];
        safeBodyString = [parseBodyString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *emailContent = [[NSArray alloc] initWithObjects:emailAddr,safeTextString,safeBodyString, nil];
    return emailContent;
    
}
- (IBAction)startNetworkObserver:(id)sender {
    [myReachability startNetworkObserver];
}

- (IBAction)stopNetworkObserver:(id)sender {
     [myReachability stopNetworkObserver];
}

- (IBAction)testWiFi:(id)sender {
    [myReachability testWiFi];
}

- (BOOL) canExecuteRequestWithCheckWiFiChanged
{
    [myReachability checkWLANWithSSID:[myReachability getCurrentWifiSSID]];
    BOOL canExecute = NO;
    return canExecute;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
