//
//  PWLocationManager.h
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PWLocationManager : NSObject

@property (nonatomic, retain) NSString *value;

+ (id)sharedManager;

- (void)checkLocationServiceEnabled;

@end
