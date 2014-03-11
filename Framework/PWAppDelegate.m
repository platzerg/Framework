//
//  PWAppDelegate.m
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWAppDelegate.h"
#import "PWFBFriedPickerViewController.h"
#import <TSMessage.h>
#import "PWFoursquareViewController.h"
#import <BZFoursquare.h>
#import <Foursquare2.h>
#import <FlickrKit.h>


@interface PWAppDelegate ()

@end


@implementation PWAppDelegate
{
    Reachability *reachability;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
     [TSMessage setDefaultViewController: self.window.rootViewController];
    [PWFBFriedPickerViewController class];
    
    [self initFlickr];
    
    return YES;
}

-(void) initFlickr
{
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:@"73767299b91be4b2db8d67de99d1da66" sharedSecret:@"75e53598d548f2f3"];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
     [self setUpRechability];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // FBSample logic
    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
    [FBAppEvents activateApp];
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // FBSample logic
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
}

// FBSample logic
// If we have a valid session at the time of openURL call, we handle Facebook transitions
// by passing the url argument to handleOpenURL; see the "Just Login" sample application for
// a more detailed discussion of handleOpenURL
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    
    NSString *scheme = [url scheme];
	if([@"flickr391994024204840" isEqualToString:scheme]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UserAuthCallbackNotification" object:url userInfo:nil];
    }
    
    if([[url host] isEqualToString:@"foursquare"])
    {
        if(_isFoursquare2)
        {
            [Foursquare2 handleURL:url];
        }
        else
        {
            return [_foursquare handleOpenURL:url];
        }
    }
    else
    {
        return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
            NSLog(@"In fallback handler");
        }];

    }
    
    return NO;
}


-(void)setUpRechability
{
    NSString* status;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        status = [NSString stringWithFormat:@"NO CONNECTION"];
    }
    else if(remoteHostStatus == ReachableViaWiFi)
    {
        status = [NSString stringWithFormat:@"WLAN"];
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        status = [NSString stringWithFormat:@"3G"];
    }
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Net avail" message:status delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //[alert show];

}

- (void) handleNetworkChange:(NSNotification *)notice
{
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    NSString* status;
    
    if (remoteHostStatus == NotReachable)
    {
        status = [NSString stringWithFormat:@"NO CONNECTION"];
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
       status = [NSString stringWithFormat:@"WLAN"];
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        status = [NSString stringWithFormat:@"3G"];
    }
    
   
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Net avail" message:status delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //[alert show];
    
}


@end
