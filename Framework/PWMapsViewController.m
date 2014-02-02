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
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if ([annotation isKindOfClass:[PWMyLocation class]]) {
            [_mapView removeAnnotation:annotation];
        }else{
            NSLog(@"TEST: %@", annotation);
        }
        
    }
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


@end
