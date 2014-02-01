//
//  PWManager.m
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWManager.h"

@implementation PWManager{
    Boolean locationServiceEnabled;
}
static NSString *const BaseURLString = @"http://biergartenservice.appspot.com/platzerworld/biergarten/holebiergarten";
@synthesize value;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static PWManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

// without GCD
+ (id)sharedGCDManager {
    static PWManager *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        value = @"Default Property Value";
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
