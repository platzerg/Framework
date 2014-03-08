//
//  PWLinkedInViewController.m
//  Framework
//
//  Created by platzerworld on 07.03.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//
/*
 https://api.linkedin.com
 /v1/jobs/1337?
 format=json
 &oauth2_access_token=AQXBpPc7qsCl6dEKjFhijC3yhg4ZFwxT_KXx1mOnBGF7QiG9UJRNHhntX9aM2QpSXxx8iCfDvpTflOqgT6kuBivfbEHqSUYejgIFRih3Hz5tcN-Z5tbOdCSXSe5MmuqhYRj99kTmsLRWqvuw_A6eokMEAdJwEII5aiGjO9neL7yvlbqNpaQ
 
 */

#import <Social/Social.h>
#import "PWLinkedInViewController.h"
#import <LIALinkedInHttpClient.h>
#import <LIALinkedInApplication.h>

@interface PWLinkedInViewController ()
- (IBAction)doLoginToLinkedIn:(id)sender;
- (IBAction)getMyConnections:(id)sender;
- (IBAction)doRequest:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *linkedInTextView;

@end

@implementation PWLinkedInViewController
{
    LIALinkedInHttpClient *_client;
    NSString *_accessToken;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _client = [self client];
}

- (IBAction)doLoginToLinkedIn:(id)sender {
    
    [self.client getAuthorizationCode:^(NSString *code) {
        [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            _accessToken = [accessTokenData objectForKey:@"access_token"];
            [self requestMeWithToken:_accessToken];
        }                   failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                      cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                     failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];

}

- (IBAction)getMyConnections:(id)sender {
    [self requestMyConnectionsWithToken:_accessToken];
}

- (IBAction)doRequest:(id)sender {
    [self requestWithURLString:@""];
}


- (void)requestMyConnectionsWithToken:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~/connections?modified=new&oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
        NSString *j = [NSString stringWithFormat:@"%@", result ];
        _linkedInTextView.text = j;
        
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _linkedInTextView.text = [NSString stringWithFormat:@"%@", error ];
        NSLog(@"failed to fetch current user %@", error);
    }];
}


- (void)requestMeWithToken:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
        NSString *j = [NSString stringWithFormat:@"%@", result ];
        _linkedInTextView.text = j;
        
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _linkedInTextView.text = [NSString stringWithFormat:@"%@", error ];
        NSLog(@"failed to fetch current user %@", error);
    }];
}

- (void) requestWithURLString:(NSString*) urlString {
    NSString *apiMethod = @"job-search";
    NSString *paramString = @"keywords=iOS&country-code=de&postal-code=80807&distance=15&sort=R";
    
    NSString* r = [NSString stringWithFormat:@"https://api.linkedin.com/v1/%@?%@&oauth2_access_token=%@&format=json", apiMethod, paramString, _accessToken ];
    
    
    
    [self.client GET:r parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
        NSString *j = [NSString stringWithFormat:@"%@", result ];
        _linkedInTextView.text = j;
        
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _linkedInTextView.text = [NSString stringWithFormat:@"%@", error ];
        NSLog(@"failed to fetch current user %@", error);
    }];
}

- (LIALinkedInHttpClient *)client {
    LIALinkedInApplication *application = [LIALinkedInApplication
            applicationWithRedirectURL:@"http://biergarten-bayern.com"
            clientId:@"7513g1iuh35sig"
            clientSecret:@"EVPgAWkLuMlFlA3k"
            state:@"DCEEFWF45453sdffef424"
            grantedAccess:@[@"r_fullprofile", @"r_network", @"r_emailaddress", @"r_contactinfo", @"rw_nus"
                            , @"rw_groups", @"w_messages", @"rw_company_admin"]];
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}
@end
