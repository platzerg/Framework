//
//  PWLocationViewController.h
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PWLocationViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startMantle;
- (IBAction)startMantle:(id)sender;

@end
