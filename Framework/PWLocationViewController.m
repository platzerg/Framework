//
//  PWLocationViewController.m
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWLocationViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "PWManager.h"

@interface PWLocationViewController ()

@end

@implementation PWLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startMantle:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[RACObserve([PWManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
      subscribeNext:^(NSArray *biergartenArray) {
          
          if(biergartenArray)
          {
              NSLog(@"subscribeNext -> %s", __PRETTY_FUNCTION__);
              NSLog(@"jsonData %@", biergartenArray);
              
              for (PWBiergarten* biergarten in biergartenArray) {
                  NSLog(@"%@", biergarten);
              }
          }
          
      }];
    
    
    [[ PWManager sharedManager] findCurrentLocation];

}

@end
