//
//  PWMapsViewController.h
//  Framework
//
//  Created by platzerworld on 02.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "PWMyLocation.h"

#define METERS_PER_MILE 1609.344

@interface PWMapsViewController : UIViewController<MKMapViewDelegate>{
    BOOL _doneInitialZoom;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)refreshTapped:(id)sender;
- (IBAction)loadBiergarten:(id)sender;

@end
