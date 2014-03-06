//
//  PWFacebookViewController.h
//  Framework
//
//  Created by platzerworld on 04.03.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PWFacebookViewController : UIViewController
- (IBAction)doPost1:(id)sender;
- (IBAction)doPost2:(id)sender;
- (IBAction)doPost3:(id)sender;
- (IBAction)doShareLinkWithShareDialog:(id)sender;
- (IBAction)doPostStatusUpdateWithShareDialog:(id)sender;

- (IBAction)doShareLinkWithAPICalls:(id)sender;
- (IBAction)doStatusUpdateWithAPICalls:(id)sender;
@end
