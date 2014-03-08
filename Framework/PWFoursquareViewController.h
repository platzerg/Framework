//
//  PWFoursquareViewController.h
//  Framework
//
//  Created by platzerworld on 07.03.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BZFoursquare.h>

@interface PWFoursquareViewController : UIViewController
@property(nonatomic,readwrite,strong) BZFoursquare *foursquare;
@end
