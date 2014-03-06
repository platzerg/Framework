//
//  PWNetworkViewController.h
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface PWNetworkViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate>

- (IBAction)showMantle:(id)sender;

- (IBAction)startNetworkNotification:(id)sender;

- (IBAction)stopNetworkNotification:(id)sender;
- (IBAction)startNetworkObserver:(id)sender;
- (IBAction)stopNetworkObserver:(id)sender;
- (IBAction)testWiFi:(id)sender;

@end
