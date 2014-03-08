//
//  PWTwitterViewController.m
//  Framework
//
//  Created by platzerworld on 06.03.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWTwitterViewController.h"
#import <Twitter/Twitter.h>
#import <OAuth.h>
#import <TwitterDialog.h>

@interface PWTwitterViewController () <TwitterDialogDelegate, TwitterLoginDialogDelegate, OAuthTwitterCallbacks>
{
    OAuth *oAuth;
}
- (IBAction)doLoginTwitterClick:(UIButton *)sender;
- (IBAction)doSocilTwitterClick:(UIButton *)sender;
@end

@implementation PWTwitterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)doLoginTwitterClick:(UIButton *)sender {
    NSLog(@"Twitter Login Button Pushed");
    
    
     oAuth = [[OAuth alloc] initWithConsumerKey:kDEConsumerKey andConsumerSecret:kDEConsumerSecret];
     oAuth.delegate = self;
    
     TwitterDialog *td = [[TwitterDialog alloc] init];
     td.twitterOAuth = oAuth;
     td.delegate = self;
     td.logindelegate = self;
     
     [td show];
    
}

- (IBAction)doSocilTwitterClick:(UIButton *)sender {
    NSLog(@"doSocilTwitterClick");
    SLComposeViewController *slc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [slc addImage: [UIImage imageNamed:@"arrest.png"]];
    [slc addURL: [NSURL URLWithString:@"http://apple.com"]];
    [self presentViewController:slc animated:YES completion:NULL];
    
}

- (void)twitterDidLogin {
    //Save Details
    //[SettingsClass setTwitterAccessToken:oAuth.oauth_token];
    //[SettingsClass setTwitterAccessSecret:oAuth.oauth_token_secret];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Sucessfully Authenticated to Twitter." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void)twitterDidNotLogin:(BOOL)cancelled {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"There was a unknown error authenticating with Twitter." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (void) authorizeTwitterTokenDidSucceed:(OAuth *)oaAuth{
    //oAuth = oaAuth;
    //[self synchronousVerifyTwitterCredentials];
    NSLog(@"authorizeTwitterTokenDidSucceed");
}

- (void) requestTwitterTokenDidSucceed:(OAuth *)oaAuth{
    //oAuth = oaAuth;
    NSLog(@"requestTwitterTokenDidSucceed");
}

- (void) authorizeTwitterTokenDidFail:(OAuth *)oAuth{
    NSLog(@"authorizeTwitterTokenDidFail");
}

- (void) requestTwitterTokenDidFail:(OAuth *)oAuth{
    NSLog(@"requestTwitterTokenDidFail");
}




/*
- (BOOL) synchronousVerifyTwitterCredentials {
	
	NSString *url = @"https://api.twitter.com/1/account/verify_credentials.json";
    
	[oAuth synchronousVerifyTwitterCredentials:url];
    return YES;
}
*/


@end
