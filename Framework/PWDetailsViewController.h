//
//  PWDetailsViewController.h
//  Framework
//
//  Created by platzerworld on 05.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWBiergarten.h"

@interface PWDetailsViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong, readwrite) PWBiergarten *biergarten;

@property (weak, nonatomic) IBOutlet UITextField *idTextView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *strasseTextView;

@property (weak, nonatomic) IBOutlet UITextField *plzTextView;
@property (weak, nonatomic) IBOutlet UITextField *ortTextView;
@property (weak, nonatomic) IBOutlet UITextField *urlTextView;

@property (weak, nonatomic) IBOutlet UITextField *telefonTextView;

@property (weak, nonatomic) IBOutlet UITextField *longitudeTextView;

@property (weak, nonatomic) IBOutlet UITextField *latitudeTextView;

@property (weak, nonatomic) IBOutlet UITextView *descTextView;

@property (weak, nonatomic) IBOutlet UITextField *emailTextView;

@property (weak, nonatomic) IBOutlet UISwitch *favoritSwitch;

- (IBAction)favoritValueChanged:(id)sender;

@end
