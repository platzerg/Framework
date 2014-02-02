//
//  PWMapsViewController.m
//  Framework
//
//  Created by platzerworld on 02.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWMapsViewController.h"

@interface PWMapsViewController ()

@end

@implementation PWMapsViewController

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

- (void)viewWillAppear:(BOOL)animated {
    // 1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 48.179712;
    zoomLocation.longitude= 11.592202;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 5.5*METERS_PER_MILE, 5.5*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// Add new method above refreshTapped
- (void)plotCrimePositions:(NSData *)responseData {
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    }
    
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    NSArray *data = [root objectForKey:@"biergartenListe"];
    
    
    for (NSArray *row in data) {
        // 48.179712;
        // 11.592202;
        
        NSLog(@"biergartenNSArraAusJson %@", row);
        
        NSString* desc = [row valueForKey:@"desc"];
        NSString* email = [row valueForKey:@"email"];
        NSString* favorit = [row valueForKey:@"favorit"];
        NSString* ids = [row valueForKey:@"id"];
        NSString* latitude = [row valueForKey:@"latitude"];
        
        latitude = [latitude stringByReplacingOccurrencesOfString:@"," withString:@"."];
        NSDecimalNumber *latitudeDezimal = [NSDecimalNumber decimalNumberWithString:latitude];
        
        NSString* longitude = [row valueForKey:@"longitude"];
        longitude = [longitude stringByReplacingOccurrencesOfString:@"," withString:@"."];
        NSDecimalNumber *longitudeDezimal = [NSDecimalNumber decimalNumberWithString:longitude];
        
        NSString* name = [row valueForKey:@"name"];
        NSString* ort = [row valueForKey:@"ort"];
        NSString* plz = [row valueForKey:@"plz"];
        NSString* strasse = [row valueForKey:@"strasse"];
        NSString* telefon = [row valueForKey:@"telefon"];
        NSString* url = [row valueForKey:@"url"];

        
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitudeDezimal.doubleValue;
        coordinate.longitude = longitudeDezimal.doubleValue;
        
        PWMyLocation *annotation = [[PWMyLocation alloc] initWithName:name address:strasse coordinate:coordinate] ;
        [_mapView addAnnotation:annotation];
	}
    
    // Default Location is Aumeister
    NSString * crimeDescription = @"Aumeister";
    NSString * address = @"Sondermeierstraße 1, 80939 München";
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude =48.185799;
    coordinate.longitude = 11.620306;
    PWMyLocation *annotation = [[PWMyLocation alloc] initWithName:crimeDescription address:address coordinate:coordinate] ;
    [_mapView addAnnotation:annotation];
    
}




// Replace refreshTapped as follows
- (IBAction)refreshTapped:(id)sender {
    [self loadBiergartenFromCloud];
}



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"PWMyLocation";
    if ([annotation isKindOfClass:[PWMyLocation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"arrest.png"];//here we use a nice image instead of the default pins
            
            // ios 6 new feature
            // Add to mapView:viewForAnnotation: after setting the image on the annotation view
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

// Add the following method
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    PWMyLocation *location = (PWMyLocation*)view.annotation;
    
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    [location.mapItem openInMapsWithLaunchOptions:launchOptions];
}


#pragma loadBiergarten
- (IBAction)loadBiergarten:(id)sender {
    [self loadBiergartenFromCloud];
}

- (void) loadBiergartenFromCloud
{
    NSString *const BaseURLString = @"http://biergartenservice.appspot.com/platzerworld/biergarten/holebiergarten";
    NSLog(@"GPL %s", __PRETTY_FUNCTION__);
    NSURLSession *session = [NSURLSession sharedSession];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading arrests...";
    
    
    [[session dataTaskWithURL:[NSURL URLWithString:BaseURLString]
            completionHandler:^(NSData *nsdata, NSURLResponse *response, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self plotCrimePositions:nsdata];
                if (error) {
                    NSLog(@"Fehler: %@", [error localizedDescription]);
                }
                
            }] resume];
}

@end
