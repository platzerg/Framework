//
//  PWRestViewController.h
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWLocationManager.h"
#import "PWNetworkManager.h"

@interface PWRestViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonSynchron1;
@property (weak, nonatomic) IBOutlet UIButton *buttonSynchron2;
@property (weak, nonatomic) IBOutlet UIButton *buttonAsynchron;
@property (weak, nonatomic) IBOutlet UIButton *buttonNSURLRequest;
@property (weak, nonatomic) IBOutlet UIButton *buttonNSURLSession;
@property (weak, nonatomic) IBOutlet UIButton *buttonDispatchQueue;
@property (weak, nonatomic) IBOutlet UIButton *buttonAFNetwork;

@property (weak, nonatomic) IBOutlet UITextView *textView;


- (IBAction)showSynchron1:(id)sender;
- (IBAction)showSynchron2:(id)sender;
- (IBAction)showAsynchron:(id)sender;
- (IBAction)showRayNSURLRequest:(id)sender;
- (IBAction)showRayNSURLSession:(id)sender;
- (IBAction)showDispatch_Queue:(id)sender;
- (IBAction)showAFNetwork:(id)sender;


@end
