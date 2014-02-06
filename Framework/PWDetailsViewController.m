//
//  PWDetailsViewController.m
//  Framework
//
//  Created by platzerworld on 05.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWDetailsViewController.h"
#import "PWBiergarten.h"


@interface PWDetailsViewController ()

@end

@implementation PWDetailsViewController

@synthesize biergarten;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.idTextView.text = [biergarten.biergartenid stringValue];
	self.nameTextField.text = biergarten.name;
    self.strasseTextView.text = biergarten.strasse;
    self.plzTextView.text = biergarten.plz;
    self.ortTextView.text = biergarten.ort;
    self.telefonTextView.text = biergarten.telefon;
    self.urlTextView.text = biergarten.url;
    self.descTextView.text = biergarten.desc;
    self.latitudeTextView.text = biergarten.latitude;
    self.longitudeTextView.text = biergarten.longitude;
    self.emailTextView.text = biergarten.email;
    
    if(_favoritSwitch.on)
    {
        NSLog(@"Favorit");
    } else
    {
        NSLog(@"kein Favorit!");
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)favoritValueChanged:(id)sender {
    if(_favoritSwitch.on)
    {
        NSLog(@"Favorit");
    } else
    {
        NSLog(@"kein Favorit!");
    }
 
}
@end
