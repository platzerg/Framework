//
//  PWManager.h
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "PWBiergarten.h"

@interface PWManager : NSObject <CLLocationManagerDelegate>{
    NSString *someProperty;
}

@property (nonatomic, retain) NSString *value;

+ (instancetype)sharedManager;

@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;

@property (nonatomic, strong, readonly) PWBiergarten *currentBiergarten;


- (void)checkLocationServiceEnabled;

- (void)findCurrentLocation;

- (void)setCurrentBiergarten:(PWBiergarten *)currentBiergarten;


@end
