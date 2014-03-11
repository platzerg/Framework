//
//  PWFlickrViewController.m
//  Framework
//
//  Created by platzerworld on 10.03.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWFlickrViewController.h"
#import <FlickrKit.h>
#import "FKPhotosViewController.h"

@interface PWFlickrViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, retain) FKFlickrNetworkOperation *todaysInterestingOp;
@property (nonatomic, retain) FKFlickrNetworkOperation *myPhotostreamOp;
@property (nonatomic, retain) FKDUNetworkOperation *completeAuthOp;
@property (nonatomic, retain) FKDUNetworkOperation *checkAuthOp;
@property (nonatomic, retain) FKImageUploadNetworkOperation *uploadOp;


@property (nonatomic, retain) NSString *userID;

@property (nonatomic, retain) FKDUNetworkOperation *authOp;

@property (weak, nonatomic) IBOutlet UILabel *authStatusLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *searchText;

- (IBAction)doLogin:(id)sender;
- (IBAction)doLogout:(id)sender;
- (IBAction)doGetPhotos:(id)sender;
- (IBAction)loadTodaysInterestingPressed:(id)sender;
- (IBAction)choosePhotoPressed:(id)sender;
- (IBAction)searchErrorPressed:(id)sender;
- (IBAction)searchPressed:(id)sender;



@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *photosButton;

@end

@implementation PWFlickrViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.loginButton.enabled = NO;
    self.logoutButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAuthenticateCallback:) name:@"UserAuthCallbackNotification" object:nil];


    // Check if there is a stored token
	// You should do this once on app launch
	self.checkAuthOp = [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
                _userID = userId;
                self.loginButton.enabled = NO;
                self.logoutButton.enabled = YES;
                self.authStatusLabel.text = [NSString stringWithFormat:@"You are logged in as %@", userName];
			} else {
				self.loginButton.enabled = YES;
                self.logoutButton.enabled = NO;
                self.authStatusLabel.text = [NSString stringWithFormat:@"Please Login"];
			}
        });
	}];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doLogin:(id)sender {
    self.webView.hidden = NO;
    if ([FlickrKit sharedFlickrKit].isAuthorized) {
		[[FlickrKit sharedFlickrKit] logout];
		self.loginButton.enabled = YES;
        self.logoutButton.enabled = NO;
        self.authStatusLabel.text = [NSString stringWithFormat:@"Please Login"];
	} else {
		
        // This must be defined in your Info.plist
        // See FlickrKitDemo-Info.plist
        // Flickr will call this back. Ensure you configure your flickr app as a web app
        NSString *callbackURLString = @"flickr391994024204840://auth";
        
        // Begin the authentication process
        self.authOp = [[FlickrKit sharedFlickrKit] beginAuthWithCallbackURL:[NSURL URLWithString:callbackURLString] permission:FKPermissionDelete completion:^(NSURL *flickrLoginPageURL, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:flickrLoginPageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
                    [self.webView loadRequest:urlRequest];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
            });		
        }];
	}
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //If they click NO DONT AUTHORIZE, this is where it takes you by default... maybe take them to my own web site, or show something else
	
    NSURL *url = [request URL];
    
	// If it's the callback url, then lets trigger that
    if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"]) {
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
            return NO;
        }
    }
	
    return YES;
	
}
- (IBAction)doLogout:(id)sender {
    [[FlickrKit sharedFlickrKit] logout];
    self.loginButton.enabled = YES;
    self.logoutButton.enabled = NO;
    self.authStatusLabel.text = [NSString stringWithFormat:@"Please Login"];
}

- (IBAction)doGetPhotos:(id)sender {
    if ([FlickrKit sharedFlickrKit].isAuthorized) {
		/*
         Example using the string/dictionary method of using flickr kit
		 */
		self.myPhotostreamOp = [[FlickrKit sharedFlickrKit] call:@"flickr.photos.search" args:@{@"user_id": self.userID, @"per_page": @"15"} maxCacheAge:FKDUMaxAgeNeverCache completion:^(NSDictionary *response, NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (response) {
					NSMutableArray *photoURLs = [NSMutableArray array];
					for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
						NSURL *url = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmall240 fromPhotoDictionary:photoDictionary];
						[photoURLs addObject:url];
					}
					NSLog(@"photoURLs");
					FKPhotosViewController *fivePhotos = [[FKPhotosViewController alloc] initWithURLArray:photoURLs];
					[self.navigationController pushViewController:fivePhotos animated:YES];
					
				} else {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
					[alert show];
				}
			});
		}];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
    
}

- (void) loadTodaysInterestingPressed:(id)sender {
	/*
     Example using the model objects
	 */
	FKFlickrInterestingnessGetList *interesting = [[FKFlickrInterestingnessGetList alloc] init];
	interesting.per_page = @"15";
	self.todaysInterestingOp = [[FlickrKit sharedFlickrKit] call:interesting completion:^(NSDictionary *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (response) {
				NSMutableArray *photoURLs = [NSMutableArray array];
				for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
					NSURL *url = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmall240 fromPhotoDictionary:photoDictionary];
					[photoURLs addObject:url];
				}
				
				FKPhotosViewController *fivePhotos = [[FKPhotosViewController alloc] initWithURLArray:photoURLs];
				[self.navigationController pushViewController:fivePhotos animated:YES];
				
			} else {
				/*
                 Iterating over specific errors for each service
				 */
				switch (error.code) {
					case FKFlickrInterestingnessGetListError_ServiceCurrentlyUnavailable:
						
						break;
					default:
						break;
				}
                
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			}
        });				
	}];
}

- (void)choosePhotoPressed:(id)sender {
	if ([FlickrKit sharedFlickrKit].isAuthorized) {
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.delegate = self;
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentViewController:imagePicker animated:YES completion:nil];
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
}

- (void)searchErrorPressed:(id)sender {
	FKFlickrPhotosSearch *search = [[FKFlickrPhotosSearch alloc] init];
	[[FlickrKit sharedFlickrKit] call:search completion:^(NSDictionary *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!response) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			}
        });
	}];
	
}

- (void)searchPressed:(id)sender {
	[self.view endEditing:YES];
	
	FKFlickrPhotosSearch *search = [[FKFlickrPhotosSearch alloc] init];
	search.text = self.searchText.text;
	search.per_page = @"15";
	[[FlickrKit sharedFlickrKit] call:search completion:^(NSDictionary *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (response) {
				NSMutableArray *photoURLs = [NSMutableArray array];
				for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
					NSURL *url = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmall240 fromPhotoDictionary:photoDictionary];
					[photoURLs addObject:url];
				}
				
				
				FKPhotosViewController *fivePhotos = [[FKPhotosViewController alloc] initWithURLArray:photoURLs];
				[self.navigationController pushViewController:fivePhotos animated:YES];
				
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			}
		});
	}];
	
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
	
    NSDictionary *uploadArgs = @{@"title": @"Test Photo", @"description": @"A Test Photo via FlickrKitDemo", @"is_public": @"0", @"is_friend": @"0", @"is_family": @"0", @"hidden": @"2"};
    
    //self.progress.progress = 0.0;
	self.uploadOp =  [[FlickrKit sharedFlickrKit] uploadImage:imagePicked args:uploadArgs completion:^(NSString *imageID, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			} else {
				NSString *msg = [NSString stringWithFormat:@"Uploaded image ID %@", imageID];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			}
            [self.uploadOp removeObserver:self forKeyPath:@"uploadProgress" context:NULL];
        });
	}];
    [self.uploadOp addObserver:self forKeyPath:@"uploadProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (void) userAuthenticateCallback:(NSNotification *)notification {
	NSURL *callbackURL = notification.object;
    self.completeAuthOp = [[FlickrKit sharedFlickrKit] completeAuthWithURL:callbackURL completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
				_userID = userId;
                self.loginButton.enabled = NO;
                self.logoutButton.enabled = YES;
                self.authStatusLabel.text = [NSString stringWithFormat:@"Angemeldeter User: %@, UserId: %@", userName, _userID];
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			}
			self.webView.hidden = YES;
		});
	}];
}

@end
