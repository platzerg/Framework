//
//  PWFoursquareViewController.m
//  Framework
//
//  Created by platzerworld on 07.03.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWFoursquareViewController.h"
#import <BZFoursquareRequest.h>
#import <BZFoursquare.h>
#import "PWAppDelegate.h"
#import <Foursquare2.h>
#import "NearbyVenuesViewController.h"

#define kClientID       @"PU305DK3MQPVEVD5X253UKVEB3FLIO0QGRGTDPOGSHR0ZNGF"
#define kCallbackURL    @"fsq391994024204840://foursquare"
#define kSecret         @"HJTTM1VDE00UQ4WOM1JBZXECRHC1GIUXP3XNR0LFVG2VMM3I"

@interface PWFoursquareViewController () <BZFoursquareRequestDelegate, BZFoursquareSessionDelegate>
- (IBAction)doLoginToFoursquare:(id)sender;

- (IBAction)doNearBy:(id)sender;
- (IBAction)doSearch:(id)sender;
- (IBAction)doCheckIn:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *foursquareTextView;

@property(nonatomic,strong) BZFoursquareRequest *request;
@property(nonatomic,copy) NSDictionary *meta;
@property(nonatomic,copy) NSArray *notifications;
@property(nonatomic,copy) NSDictionary *response;


- (void)cancelRequest;
- (void)prepareForRequest;
- (void)searchVenues;
- (void)checkin;
- (void)addPhoto;
@end

@implementation PWFoursquareViewController
{
    NSString *accessToken;
    PWAppDelegate *appDel;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    appDel =(PWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.foursquare = [[BZFoursquare alloc] initWithClientID:kClientID callbackURL:kCallbackURL];
    _foursquare.version = @"20120609";
    _foursquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    _foursquare.sessionDelegate = self;
    appDel.foursquare = _foursquare;

}

- (void)dealloc {
    _foursquare.sessionDelegate = nil;
    [self cancelRequest];
}

- (IBAction)doLoginToFoursquare:(id)sender {
    appDel.isFoursquare2 = NO;
    if (![_foursquare isSessionValid]) {
        _foursquareTextView.text = @"Obtain Access Token";
    } else {
        _foursquareTextView.text = @"Forget Access Token";
    }
    
    if (![_foursquare isSessionValid]) {
        [_foursquare startAuthorization];
        _foursquareTextView.text = @"startAuthorization";
    } else {
        [_foursquare invalidateSession];
        _foursquareTextView.text = @"invalidateSession";
    }
}

- (IBAction)doNearBy:(id)sender {
    appDel.isFoursquare2 = NO;
    [self addPhoto];
}

- (IBAction)doSearch:(id)sender {
    appDel.isFoursquare2 = NO;
    [self searchVenues];
}

- (IBAction)doCheckIn:(id)sender {
    appDel.isFoursquare2 = NO;
    [self checkin];
}

#pragma mark BZFoursquareRequestDelegate
- (void)requestDidStartLoading:(BZFoursquareRequest *)request
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    self.meta = request.meta;
    self.notifications = request.notifications;
    self.response = request.response;
    NSLog(@"%@", self.meta);
    NSLog(@"%@", self.notifications);
    NSLog(@"%@", self.request);
    self.request = nil;
    self.foursquareTextView.text = [NSString stringWithFormat:@"%@", self.response];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error userInfo][@"errorDetail"] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    [alertView show];
    self.meta = request.meta;
    self.notifications = request.notifications;
    self.response = request.response;
    self.request = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark BZFoursquareSessionDelegate

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    accessToken = foursquare.accessToken;
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, foursquare);
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, errorInfo);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowApiV2"]) {
        appDel.isFoursquare2 = YES;
        [Foursquare2 setupFoursquareWithClientId:kClientID
                                          secret:kSecret
                                     callbackURL:kCallbackURL];
    }
}



- (void)cancelRequest {
    if (_request) {
        _request.delegate = nil;
        [_request cancel];
        self.request = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)prepareForRequest {
    [self cancelRequest];
    self.meta = nil;
    self.notifications = nil;
    self.response = nil;
}

- (void)searchVenues {
    [self prepareForRequest];
    NSDictionary *parameters = @{@"ll": @"48.179796, 11.592184"};
    self.request = [_foursquare requestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
    self.request.delegate = self;
    [_request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)checkin {
    [self prepareForRequest];
    NSDictionary *parameters = @{@"venueId": @"4d341a00306160fcf0fc6a88", @"broadcast": @"public"};
    self.request = [_foursquare requestWithPath:@"checkins/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
    self.request.delegate = self;
    [_request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)addPhoto {
    [self prepareForRequest];
    NSURL *photoURL = [[NSBundle mainBundle] URLForResource:@"TokyoBa-Z" withExtension:@"jpg"];
    NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
    NSDictionary *parameters = @{@"photo.jpg": photoData, @"venueId": @"4d341a00306160fcf0fc6a88"};
    self.request = [_foursquare requestWithPath:@"photos/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
    self.request.delegate = self;
    [_request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
@end
