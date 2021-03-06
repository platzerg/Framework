//
//  PWAppDelegate.h
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Reachability.h>
#import <FacebookSDK/FacebookSDK.h>
#import <BZFoursquare.h>
#import <Foursquare2.h>

@interface PWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BZFoursquare *foursquare;
@property  BOOL isFoursquare2;
@end
