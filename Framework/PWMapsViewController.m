//
//  PWMapsViewController.m
//  Framework
//
//  Created by platzerworld on 02.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWMapsViewController.h"
#import "PWManager.h"

@interface PWMapsViewController ()
@end

@implementation PWMapsViewController

@synthesize locationManager, biergarten, mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Create location manager with filters set for battery efficiency.
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Start updating location changes.
	[locationManager startUpdatingLocation];

}

- (void)viewWillAppear:(BOOL)animated {
    // 1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 48.179712;
    zoomLocation.longitude= 11.592202;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 5.5*METERS_PER_MILE, 5.5*METERS_PER_MILE);
    // 3
    [mapView setRegion:viewRegion animated:YES];
}

- (void)viewDidUnload {
	self.locationManager.delegate = nil;
	self.locationManager = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Add new method above refreshTapped
- (void)plotCrimePositions:(NSData *)responseData {
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[PWMyLocation class]])
        {
            [mapView removeAnnotation:annotation];
        }
        
    }
    
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    NSArray *data = [root objectForKey:@"biergartenListe"];
    
    PWBiergarten* biergarten = nil;
    
    for (NSArray *row in data) {
        // 48.179712;
        // 11.592202;
        biergarten = [MTLJSONAdapter modelOfClass:[PWBiergarten class] fromJSONDictionary:row error:nil];
        
        NSLog(@"biergartenNSArraAusJson %@", row);
        
        BOOL boolValue = [[row valueForKey:@"favorit"] boolValue];
        
        biergarten.latitude = [biergarten.latitude stringByReplacingOccurrencesOfString:@"," withString:@"."];
        NSDecimalNumber *latitudeDezimal = [NSDecimalNumber decimalNumberWithString:biergarten.latitude];
        
        biergarten.longitude = [biergarten.longitude stringByReplacingOccurrencesOfString:@"," withString:@"."];
        NSDecimalNumber *longitudeDezimal = [NSDecimalNumber decimalNumberWithString:biergarten.longitude];
        
        PWMyLocation *annotation = [[PWMyLocation alloc] initWithName:biergarten.name
                                                        address:biergarten.strasse
                                                        coordinate:CLLocationCoordinate2DMake(latitudeDezimal.doubleValue, longitudeDezimal.doubleValue)] ;
        annotation.biergarten = biergarten;
        [mapView addAnnotation:annotation];
	}
    
    /*
    // Default Location is Aumeister
    NSString * crimeDescription = @"Aumeister";
    NSString * address = @"Sondermeierstraße 1, 80939 München";
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude =48.185799;
    coordinate.longitude = 11.620306;
    PWMyLocation *annotation = [[PWMyLocation alloc] initWithName:crimeDescription address:address coordinate:coordinate] ;
    [_mapView addAnnotation:annotation];
    */
}




// Replace refreshTapped as follows
- (IBAction)refreshTapped:(id)sender {
    [self loadBiergartenFromCloud];
}



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"PWMyLocation";

    if ([annotation isKindOfClass:[PWMyLocation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"arrest.png"];//here we use a nice image instead of the default pins
            
            // ios 6 new feature
            // Add to mapView:viewForAnnotation: after setting the image on the annotation view
            
            UIButton *removeRegionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            removeRegionButton.tag = 1;
			[removeRegionButton setFrame:CGRectMake(0., 0., 25., 25.)];
			[removeRegionButton setImage:[UIImage imageNamed:@"RemoveRegion"] forState:UIControlStateNormal];
			annotationView.leftCalloutAccessoryView = removeRegionButton;
            

            
            UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            mapButton.tag = 2;
            annotationView.rightCalloutAccessoryView = mapButton;
          
            
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }else if([annotation isKindOfClass:[RegionAnnotation class]]) {
		RegionAnnotation *currentAnnotation = (RegionAnnotation *)annotation;
		RegionAnnotationView *regionView = (RegionAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"RegionAnnotation"];
		
		if (!regionView) {
			regionView = [[RegionAnnotationView alloc] initWithAnnotation:currentAnnotation withIdentifier:@"RegionAnnotation"];
			regionView.map = mapView;
			
            // Create a button for the left callout accessory view of each annotation to remove the annotation and region being monitored.
			UIButton *removeRegionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            removeRegionButton.tag = 3;
            
			[removeRegionButton setFrame:CGRectMake(0., 0., 25., 25.)];
			[removeRegionButton setImage:[UIImage imageNamed:@"RemoveRegion"] forState:UIControlStateNormal];
			
			regionView.leftCalloutAccessoryView = removeRegionButton;
		} else {
			regionView.annotation = annotation;
			regionView.theAnnotation = annotation;
		}
		
		// Update or add the overlay displaying the radius of the region around the annotation.
		[regionView updateRadiusOverlay];
		
		return regionView;
	}
    
    return nil;
}

// Add the following method
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if ([view.annotation isKindOfClass:[PWMyLocation class]]) {
        
        UIButton* leftButton = (UIButton*)control;
        if (leftButton.tag == 1) {
            MKAnnotationView *regionView = (MKAnnotationView *)view;
            if ([regionView.annotation isKindOfClass:[PWMyLocation class]]) {
                [mapView removeAnnotation:regionView.annotation];
            }else {
                NSLog(@"TEST: %@", regionView.annotation);
            }
        }
        else if (leftButton.tag == 2)
        {
            PWMyLocation* location = (PWMyLocation*)view.annotation;
            
            // NSString* d = [NSString stringWithFormat:@"%@",location.biergarten ];
            // [TSMessage showNotificationWithTitle:@"INFO" subtitle:d type:TSMessageNotificationTypeSuccess];
            
            /*
            UIViewController *toViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherViewControllerId"];
            MyCustomSegue *segue = [[MyCustomSegue alloc] initWithIdentifier:@"" source:self destination:toViewController];
            [self prepareForSegue:segue sender:sender];
            [segue perform];
             
             PWDetailsViewController *cvc = [[PWDetailsViewController alloc] init];
             [self.navigationController pushViewController:cvc animated:YES];

            */
            
            self.biergarten = location.biergarten;
            [self performSegueWithIdentifier:@"PWDetail" sender:control];
            
            // [[PWManager sharedManager] setCurrentBiergarten:self.biergarten];
            
           // NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
           // [location.mapItem openInMapsWithLaunchOptions:launchOptions];
        }
        
    }
    else{
        RegionAnnotationView *regionView = (RegionAnnotationView *)view;
        RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
        
        // Stop monitoring the region, remove the radius overlay, and finally remove the annotation from the map.
        [locationManager stopMonitoringForRegion:regionAnnotation.region];
        [regionView removeRadiusOverlay];
        [mapView removeAnnotation:regionAnnotation];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PWDetail"])
    {
        PWDetailsViewController *details = [segue destinationViewController];
        details.biergarten = biergarten;
    }
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
    
    /*
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    */
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Biergarten...";
    hud.dimBackground = YES;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[session dataTaskWithURL:[NSURL URLWithString:BaseURLString]
                completionHandler:^(NSData *nsdata, NSURLResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Fehler: %@", [error localizedDescription]);
                    }
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self plotCrimePositions:nsdata];
                    });
                
                }] resume];
    });
    
}

#pragma deleteAllBiergarten
- (IBAction)deleteAllBiergarten:(id)sender {
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[PWMyLocation class]]) {
            [mapView removeAnnotation:annotation];
        }else {
            NSLog(@"TEST: %@", annotation);
        }
    }
    
    /*
    
    RegionAnnotationView *mRegionView = (RegionAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"RegionAnnotation"];
    RegionAnnotation *regionAnnotation = (RegionAnnotation *)mRegionView.annotation;
    [mRegionView updateRadiusOverlay];
    // Stop monitoring the region, remove the radius overlay, and finally remove the annotation from the map.
    [locationManager stopMonitoringForRegion:regionAnnotation.region];
    
    */
}


# pragma Google Places
- (IBAction)showGooglePlaces:(id)sender {
    [self queryGooglePlaces:@"food"];
}

-(void) queryGooglePlaces: (NSString *) googleType
{
    
    CLLocationCoordinate2D currentCentre;
    currentCentre = self.mapView.centerCoordinate;
    
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    //Set our current distance instance variable.
    int currenDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", currentCentre.latitude, currentCentre.longitude, [NSString stringWithFormat:@"%i", currenDist], googleType, kGOOGLE_API_KEY];
    
    NSString *urlTextSearch = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=biergarten+in+M&umlunchen&sensor=true&key=%@",kGOOGLE_API_KEY];
    
    /*
    [Status Code:]
    - ZERO_RESULTS indicates that the search was successful but returned no results. This may occur if the search was passed a latlng in a remote location.
    - OVER_QUERY_LIMIT indicates that you are over your quota.
    - REQUEST_DENIED indicates that your request was denied, generally because of lack of a sensor parameter.
    - INVALID_REQUEST generally indicates that a required query parameter (location or radius) is missing.
     */
    // 48.185799;
    // 11.620306;
    
    // https://developers.google.com/places/documentation/search
    // https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=48.179385,11.592202&radius=14887&types=Bar&sensor=true&key=AIzaSyBp2EcWAYlzzJSgSDySxh4GiH9BzgerBBc
    
    //nearbysearch: https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=harbour&sensor=false&key=AIzaSyBp2EcWAYlzzJSgSDySxh4GiH9BzgerBBc
    
    //textsearch: https://maps.googleapis.com/maps/api/place/textsearch/json?query=biergarten+in+M&umlunchen&sensor=true&key=AIzaSyBp2EcWAYlzzJSgSDySxh4GiH9BzgerBBc

    //radarsearch: https://maps.googleapis.com/maps/api/place/radarsearch/json?location=51.503186,-0.126446&radius=5000&types=museum&sensor=false&key=AIzaSyBp2EcWAYlzzJSgSDySxh4GiH9BzgerBBc
    
    //aditional result: https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&rankby=distance&types=food&sensor=false&key=AIzaSyBp2EcWAYlzzJSgSDySxh4GiH9BzgerBBc
    
    // https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=ClRIAAAAA6_80mA3VbkPRTawH0Fc2qv2zh28FA-D0RdPQqugFRuWxAk7vFADFjNH4JV65CtFn9s1qE2CpWUN-Ek42X1PU38TEnUaTvBPhnG2HjIcXUESEAVZmD0zcmFe9zOhCsFeVmkaFLDwndrZeaOww2hPyY6_zC07v0UJ&sensor=false&key=AIzaSyBp2EcWAYlzzJSgSDySxh4GiH9BzgerBBc
    
    
    //nextPage: https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&rankby=distance&types=food&sensor=false&key=AIzaSyBp2EcWAYlzzJSgSDySxh4GiH9BzgerBBc
    // -
    //https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=ClRPAAAA1sp4ohu_TccyUB4WlvteEoRTR4uqLiKmd-cyfJoIRI1zj_GtuQ2iUI2lPPKRLTa_Mon96IuEjzYtq3m2Qu90z7GzY8vf2KZBDX5CH1AEtc8SEF_zcd6bh3xSnVAeoSfrFBsaFBpEujOjaw_hcuFCswN5l-6Bb2nV&sensor=false&key=AIzaSyBp2EcWAYlzzJSgSDySxh4GiH9BzgerBBc
    
    
    
    //Formulate the string as URL object. urlTextSearch
    NSURL *googleRequestURL=[NSURL URLWithString:urlTextSearch];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        
        NSString * h = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"data: %@", h);
        
        
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}
- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
    
    //Plot the data in the places array onto the map with the plotPostions method.
    [self plotPositions:places];
}
- (void)plotPositions:(NSArray *)data
{
    //Remove any existing custom annotations but not the user location blue dot.
    for (id<MKAnnotation> annotation in self.mapView.annotations)
    {
        if ([annotation isKindOfClass:[PWMyLocation class]])
        {
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    
    //Loop through the array of places returned from the Google API.
    for (int i=0; i<[data count]; i++)
    {
        
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary* place = [data objectAtIndex:i];
        
        //There is a specific NSDictionary object that gives us location info.
        NSDictionary *geo = [place objectForKey:@"geometry"];
        
        //Get our name and address info for adding to a pin.
        NSString *name=[place objectForKey:@"name"];
        NSString *vicinity=[place objectForKey:@"vicinity"];
        
        //Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        
        //Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        //Create a new annotiation.
        PWMyLocation *placeObject = [[PWMyLocation alloc] initWithName:name address:vicinity coordinate:placeCoord];
        
        
        [self.mapView addAnnotation:placeObject];
    }
}

- (IBAction)addRegion:(id)sender {
    NSLog(@"addRegion");
    if ([CLLocationManager regionMonitoringAvailable]) {
		// Create a new region based on the center of the map view.
		CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
		CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:coord
																	  radius:6000.0
																  identifier:[NSString stringWithFormat:@"%f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude]];
		
		// Create an annotation to show where the region is located on the map.
		RegionAnnotation *myRegionAnnotation = [[RegionAnnotation alloc] initWithCLRegion:newRegion];
		myRegionAnnotation.coordinate = newRegion.center;
		myRegionAnnotation.radius = newRegion.radius;
		
		[mapView addAnnotation:myRegionAnnotation];
		
		// Start monitoring the newly created region.
		[locationManager startMonitoringForRegion:newRegion desiredAccuracy:kCLLocationAccuracyBest];
	}
	else {
		NSLog(@"Region monitoring is not available.");
	}
}



- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	if([overlay isKindOfClass:[MKCircle class]]) {
		// Create the view for the radius overlay.
		MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
		circleView.strokeColor = [UIColor purpleColor];
		circleView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.4];
		
		return circleView;
	}
	
	return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	if([annotationView isKindOfClass:[RegionAnnotationView class]]) {
		RegionAnnotationView *regionView = (RegionAnnotationView *)annotationView;
		RegionAnnotation *regionAnnotation = (RegionAnnotation *)regionView.annotation;
		
		// If the annotation view is starting to be dragged, remove the overlay and stop monitoring the region.
		if (newState == MKAnnotationViewDragStateStarting) {
			[regionView removeRadiusOverlay];
			
			[locationManager stopMonitoringForRegion:regionAnnotation.region];
		}
		
		// Once the annotation view has been dragged and placed in a new location, update and add the overlay and begin monitoring the new region.
		if (oldState == MKAnnotationViewDragStateDragging && newState == MKAnnotationViewDragStateEnding) {
			[regionView updateRadiusOverlay];
			
			CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:regionAnnotation.coordinate radius:1000.0 identifier:[NSString stringWithFormat:@"%f, %f", regionAnnotation.coordinate.latitude, regionAnnotation.coordinate.longitude]];
			regionAnnotation.region = newRegion;
			
			[locationManager startMonitoringForRegion:regionAnnotation.region desiredAccuracy:kCLLocationAccuracyBest];
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
	
	// Work around a bug in MapKit where user location is not initially zoomed to.
	if (oldLocation == nil) {
		// Zoom to the current user location.
		//MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
		[mapView setRegion:[self getMKCoordinateRegionWithLocation:newLocation] animated:YES];
	}
}

- (MKCoordinateRegion) getMKCoordinateRegionWithLocation: (CLLocation *)newLocation
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = newLocation.coordinate.latitude;
    zoomLocation.longitude= newLocation.coordinate.longitude;
    
    // 2
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(zoomLocation, 5000, 5000);
    
    return region;
}

- (IBAction)zoomIn:(id)sender
{
    MKCoordinateRegion region = mapView.region;
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = region.center.latitude;
    zoomLocation.longitude= region.center.longitude;
    
    double laa = region.span.latitudeDelta;
    double loo = region.span.longitudeDelta;
    
    double la = region.span.latitudeDelta*METERS_PER_MILE;
    double lo = region.span.longitudeDelta*METERS_PER_MILE;
    
    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(zoomLocation,
             1500,  1500);
    
    
    [mapView setRegion:newRegion animated:YES];
}

- (IBAction)zoomOut:(id)sender
{
    MKCoordinateRegion region = mapView.region;
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = region.center.latitude;
    zoomLocation.longitude= region.center.longitude;
    
    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(zoomLocation,
                                                                      6000,  6000);
    
    [mapView setRegion:newRegion animated:YES];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region  {
	NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
	
	
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", region.identifier, [NSDate date]];
	
	
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
	
}




@end
