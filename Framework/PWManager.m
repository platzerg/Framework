//
//  PWManager.m
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWManager.h"
#import <TSMessages/TSMessage.h>
#import "PWManager.h"
#import "PWBiergartenClient.h"

@interface PWManager ()

@property (nonatomic, strong, readwrite) PWBiergarten *currentBiergarten;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) PWBiergartenClient *client;


@end

@implementation PWManager{
    Boolean locationServiceEnabled;
}

static NSString *const BaseURLString = @"http://biergartenservice.appspot.com/platzerworld/biergarten/holebiergarten";
@synthesize value;




#pragma mark Singleton Methods

+ (instancetype)sharedManager {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        value = @"Default Property Value";
        _client = [[PWBiergartenClient alloc] init];
        
        [[[[RACObserve(self, currentLocation)
            ignore:nil]
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               NSLog(@"flattenMap -> %s", __PRETTY_FUNCTION__);
               return [RACSignal merge:@[ [self updateHourlyForecast] ]];
           }] deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the latest weather." type:TSMessageNotificationTypeError];
         }];
        
        
         }
    return self;
}

- (void)findCurrentLocation {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }else{
        CLLocation *location = [locations lastObject];
        
        if (location.horizontalAccuracy > 0) {
            [self.locationManager stopUpdatingLocation];
            self.currentLocation = location;
            [self.locationManager setDelegate:nil];
        }
    }
    
    
}

- (RACSignal *)updateHourlyForecast {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
    }];
}


- (void)checkLocationServiceEnabled
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    if (manager.locationServicesEnabled == NO) {
        locationServiceEnabled = false;
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }else{
        locationServiceEnabled = true;
    }
    if(locationServiceEnabled == true){
        NSLog(@"LocationService enabled");
    }else{
        NSLog(@"LocationService disabled");
    }
}

- (void)setCurrentBiergarten:(PWBiergarten *)currentBiergarten
{
    self.currentBiergarten = currentBiergarten;
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
