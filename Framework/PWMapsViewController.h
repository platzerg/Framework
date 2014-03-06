//
//  PWMapsViewController.h
//  Framework
//
//  Created by platzerworld on 02.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "PWMyLocation.h"
#import "RegionAnnotation.h"
#import "RegionAnnotationView.h"
#import "PWBiergarten.h"
#import <TSMessage.h>
#import "PWDetailsViewController.h"

#define METERS_PER_MILE 1609.344
// #define kGOOGLE_API_KEY @"AIzaSyDL4y7nosmZoAhIiHAqcYMqW5_M7q69_yI"
#define kGOOGLE_API_KEY @"AIzaSyBp2EcWAYlzzJSgSDySxh4GiH9BzgerBBc"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface PWMapsViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>{
    BOOL _doneInitialZoom;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) PWBiergarten *biergarten;

- (IBAction)refreshTapped:(id)sender;
- (IBAction)loadBiergarten:(id)sender;
- (IBAction)deleteAllBiergarten:(id)sender;
- (IBAction)showGooglePlaces:(id)sender;
- (IBAction)addRegion:(id)sender;
- (IBAction)zoomIn:(id)sender;

- (IBAction)zoomOut:(id)sender;
@end
