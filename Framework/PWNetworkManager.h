//
//  PWNetworkManager.h
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Reachability.h>

@interface PWNetworkManager : NSObject

@property (nonatomic, retain) NSString *value;

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;


+ (id)sharedManager;

- (BOOL)checkNetworkIsEnabled;

- (void)removePWObservers;
- (void)addPWObservers;

@end
