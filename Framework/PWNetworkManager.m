//
//  PWNetworkManager.m
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWNetworkManager.h"


@implementation PWNetworkManager{
    Boolean networkServiceEnabled;
    UIAlertView *servicesDisabledAlert;
    NetworkStatus netStatus;
    
}

NSString *remoteHostName = @"http://biergartenservice.appspot.com/platzerworld/biergarten/holebiergarten";

+ (id)sharedManager {
    static PWNetworkManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        networkServiceEnabled = false;
        
        [self addPWObservers];
        
        [self checkHostReachability];
        [self checkInternetReachability];
        [self checkWifiReachability];
        
        
        if (networkServiceEnabled) {
            servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"NetworkCheck" message:@"Network reachable" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        } else {
           servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"NetworkCheck" message:@"Network not reachable" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
        [servicesDisabledAlert show];

    }
    return self;
}

- (BOOL) checkHostReachability
{
    if(!networkServiceEnabled)
    {
        
        self.hostReachability = [Reachability reachabilityWithHostname:@"apple.com"];
        [self.hostReachability startNotifier];
        [self updateInterfaceWithReachability:self.hostReachability];
        
        [self setNetworkServiceEnabledFor:self.hostReachability];

    }
    return networkServiceEnabled;
}

- (BOOL) checkInternetReachability
{
    if(!networkServiceEnabled)
    {
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
        [self updateInterfaceWithReachability:self.internetReachability];
        
        [self setNetworkServiceEnabledFor:self.internetReachability];


    }
    return networkServiceEnabled;
}

- (BOOL) checkWifiReachability
{
    if(!networkServiceEnabled)
    {
        self.wifiReachability = [Reachability reachabilityForLocalWiFi];
        [self.wifiReachability startNotifier];
        [self updateInterfaceWithReachability:self.wifiReachability];
        
        [self setNetworkServiceEnabledFor:self.wifiReachability];

    }
    return networkServiceEnabled;
}

-(void) setNetworkServiceEnabledFor: (Reachability*)reachability
{
    netStatus = [reachability currentReachabilityStatus];
    if (netStatus==ReachableViaWiFi) {
        networkServiceEnabled = true;
    } else if(netStatus==ReachableViaWWAN) {
        networkServiceEnabled = true;
    } else {
        networkServiceEnabled = false;
    }
}


- (BOOL)checkNetworkIsEnabled
{
    if(networkServiceEnabled == true){
        NSLog(@"NetworkService enabled");
        return true;
    }else{
        NSLog(@"NetworkService disabled");
        return false;
    }
}


- (void)addPWObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}
- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}
- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
	{
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];
        
        BOOL hiden = (netStatus != ReachableViaWWAN);
        NSString* baseLabelText = @"";
        
        if (connectionRequired)
        {
            [self configureReachability:reachability];
            NSLog(@"connectionRequired=yes");
        }
        else
        {
           NSLog(@"connectionRequired=no");
            [self configureReachability:reachability];
        }
       
    }
    
	if (reachability == self.internetReachability)
	{
        [self configureReachability:reachability];
    }
    
	if (reachability == self.wifiReachability)
	{
		[self configureReachability:reachability];
	}
}


- (void)configureReachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    NSString* statusString = @"";
    
    switch (netStatus)
    {
        case NotReachable:        {
            networkServiceEnabled = false;
            statusString = @"Access Not Available";
           
            connectionRequired = NO;
            break;
        }
            
        case ReachableViaWWAN:        {
            statusString = @"Reachable WWAN";
            networkServiceEnabled = true;
            break;
        }
        case ReachableViaWiFi:        {
            networkServiceEnabled = true;
            statusString= @"Reachable WiFi";
            break;
        }
        default:
            statusString = @"Unknown";
            break;
    }
    
    if (connectionRequired)
    {
        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    }
    NSLog(@"statusString %@", statusString);
}


- (void)removePWObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)dealloc {
    [self removePWObservers];
}

@end
