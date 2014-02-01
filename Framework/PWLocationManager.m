//
//  PWLocationManager.m
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWLocationManager.h"

@implementation PWLocationManager{
    Boolean locationServiceEnabled;
}

@synthesize value;

+ (id)sharedManager {
    static PWLocationManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        locationServiceEnabled = false;
    }
    return self;
}


- (void)checkLocationServiceEnabled
{
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


- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
