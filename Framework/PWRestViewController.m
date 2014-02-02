//
//  PWRestViewController.m
//  Framework
//
//  Created by platzerworld on 01.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWRestViewController.h"

@interface PWRestViewController ()

@end

@implementation PWRestViewController{}

static NSString *const BaseURLString = @"http://biergartenservice.appspot.com/platzerworld/biergarten/holebiergarten";

NSURLResponse* urlResponse;

NSURLResponse* urlResponse;

NSData* biergartenResponseNSData;

NSString* biergartenResponseDataAsString;
NSArray *biergartenResponseDataAsStringJsonObject;

NSArray *jsonResponseDictionaryNSData;


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
    [[PWLocationManager sharedManager]checkLocationServiceEnabled];
    bool buttonsEnabled = [[PWNetworkManager sharedManager]checkNetworkIsEnabled];
    
    self.buttonSynchron1.enabled = buttonsEnabled;
    self.buttonSynchron2.enabled = buttonsEnabled;
    self.buttonAsynchron.enabled = buttonsEnabled;
    self.buttonNSURLRequest.enabled = buttonsEnabled;
    self.buttonNSURLSession.enabled = buttonsEnabled;
    self.buttonDispatchQueue.enabled = buttonsEnabled;
    self.buttonAFNetwork.enabled = buttonsEnabled;
   
    
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (void) setBiergartenDataNSURLConnectionSynchronResponse
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSError* error;
    NSURLResponse* urlResponse;
    
    // 1. Erzeugen einer NSURL
    NSURL* url = [NSURL URLWithString:BaseURLString];
    // 2. Erzeugen eines NSURLRequest
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
    
    // 3. Synchroner Aufruf mit urlResponse und error als call by reference
    // NSData
    biergartenResponseNSData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
    // Fehlerbehandlung bei evtl. aufgetretenem fehler
    if (error) {
        NSLog(@"Fehler: %@", [error localizedDescription]);
    }
    error = nil;
    
    // 5. NSArray aus NSData erzeugen
    NSArray* biergartenNSArraAusJson = [NSJSONSerialization JSONObjectWithData:biergartenResponseNSData options:0 error:&error];
    // Fehlerbehandlung bei evtl. aufgetretenem fehler
    if (error) {
        NSLog(@"Fehler: %@", [error localizedDescription]);
    }
    
    NSLog(@"biergartenNSArraAusJson %@", biergartenNSArraAusJson);
    
    // 5. a) Erzeugung eines NSString mit NSData und NSUTF8StringEncoding
    biergartenResponseDataAsString = [[NSString alloc] initWithData:biergartenResponseNSData encoding:NSUTF8StringEncoding];
    
    // 6. Aus einem JSON-String ein NSArray erzeugen
    biergartenResponseDataAsStringJsonObject = [NSJSONSerialization JSONObjectWithData:[biergartenResponseDataAsString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
}

- (void) setBiergartenDataNSURLConnectionAsynchronResponse
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSError* error;
    self.textView.text = @"";
    
    // 1. Erzeugen einer NSURL
    NSURL* url = [NSURL URLWithString:BaseURLString];
    // 2. Erzeugen eines NSURLRequest
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 3. Asynchroner Aufruf mit urlResponse und error als call by reference
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err) {
        
        // 4. Fehlerbehandlung bei evtl. aufgetretenem fehler
        if (error) {
            NSLog(@"Fehler: %@", [error localizedDescription]);
        }
        
        NSError* merror;
        // 5. NSArray aus NSData erzeugen
        NSArray* biergartenNSArraAusJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&merror];
        // 4. Fehlerbehandlung bei evtl. aufgetretenem fehler
        if (merror) {
            NSLog(@"Fehler: %@", [error localizedDescription]);
        }
        
        NSLog(@"biergartenNSArraAusJson %@", biergartenNSArraAusJson);
        
        biergartenResponseNSData = data;
        
        // 5. a) Erzeugung eines NSString mit NSData und NSUTF8StringEncoding
        biergartenResponseDataAsString = [[NSString alloc] initWithData:biergartenResponseNSData encoding:NSUTF8StringEncoding];
        
        // 6. Aus einem JSON-String ein NSArray erzeugen
        biergartenResponseDataAsStringJsonObject = [NSJSONSerialization JSONObjectWithData:[biergartenResponseDataAsString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
        
        NSLog(@"biergartenResponseDataAsString = %@", biergartenResponseDataAsString);
        NSLog(@"biergartenResponseDataAsStringJsonObject=%@", biergartenResponseDataAsStringJsonObject);
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.textView.text = [biergartenResponseDataAsStringJsonObject description];
            
        });
        
    }];
}




- (IBAction)showSynchron1:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.textView.text = @"";
    
    NSError* error;
    
    // Befüllung der biergartenResponseData
    [self setBiergartenDataNSURLConnectionSynchronResponse];
    
    NSLog(@"biergartenResponseDataAsString = %@", biergartenResponseDataAsString);
    NSLog(@"biergartenResponseDataAsStringJsonObject=%@", biergartenResponseDataAsStringJsonObject);
    
    // 5. b) Erzeugung eines NSDictionary durch NSJSONSerialization mit NSData, options und error
    NSDictionary *jsonResponseDictionary = [NSJSONSerialization JSONObjectWithData:biergartenResponseNSData options:kNilOptions error:&error];
    NSLog(@"jsonResponseDictionary = %@", jsonResponseDictionary);
    
    // 5. c) aus dem jsonResponseDictionary alle Objekte "biergartenListe" in ein NSArray konvertieren
    jsonResponseDictionaryNSData = [jsonResponseDictionary valueForKey:@"biergartenListe"];
    NSLog(@"tableData=%@", jsonResponseDictionaryNSData);
    
    self.textView.text = [jsonResponseDictionaryNSData description];

}

- (IBAction)showSynchron2:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSError* error;
    
    self.textView.text = @"";
    
    
    // Befüllung der biergartenResponseData
    [self setBiergartenDataNSURLConnectionSynchronResponse];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:biergartenResponseDataAsStringJsonObject options:NSJSONWritingPrettyPrinted error:&error];
    NSLog(@"jsonData %@", jsonData);
    
    if (error) {
        NSLog(@"Fehler: %@", [error localizedDescription]);
    }
    
    // Aus einem DataAsString ein NSData ermitteln (langer Stile).
    NSData* jsonStringToData = [biergartenResponseDataAsString dataUsingEncoding:NSUTF8StringEncoding];    error = nil;
    NSArray* datenbankAusJson = [NSJSONSerialization JSONObjectWithData:jsonStringToData options:0 error:&error];
    NSLog(@"datenbankAusJson %@", datenbankAusJson);
    
    self.textView.text = [datenbankAusJson description];

}

- (IBAction)showAsynchron:(id)sender {
    NSLog(@"Ende %s", __PRETTY_FUNCTION__);
    // Befüllung der biergartenResponseData Asynchron
    [self setBiergartenDataNSURLConnectionAsynchronResponse];
    NSLog(@"Ende %s", __PRETTY_FUNCTION__);
}

- (IBAction)showRayNSURLRequest:(id)sender {
    // alt Ray Wenderlich mit NSURLRequest, NSURLConnection, MainQueue und asynchron
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.textView.text = @"";
    
    
    // 1. Erzeugen eines NSURLRequest (kurzer Stil)
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:BaseURLString]];
    
    // 2. Asynchroner Aufruf mit mit NSURLRequest, NSURLConnection, MainQueue
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               // 3. Fehlerbehandlung bei evtl. aufgetretenem fehler
                               if (connectionError) {
                                   NSLog(@"Fehler: %@", [connectionError localizedDescription]);
                               }
                               biergartenResponseNSData = data;
                               
                               // 4. a) Erzeugung eines NSString mit NSData und NSUTF8StringEncoding
                               biergartenResponseDataAsString = [[NSString alloc] initWithData:biergartenResponseNSData encoding:NSUTF8StringEncoding];
                               
                               // 5. Aus einem JSON-String ein NSArray erzeugen
                               biergartenResponseDataAsStringJsonObject = [NSJSONSerialization JSONObjectWithData:[biergartenResponseDataAsString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
                               
                               NSLog(@"biergartenResponseDataAsString = %@", biergartenResponseDataAsString);
                               NSLog(@"biergartenResponseDataAsStringJsonObject=%@", biergartenResponseDataAsStringJsonObject);
                               
                               self.textView.text = [biergartenResponseDataAsStringJsonObject description];
                           }];
}

- (IBAction)showRayNSURLSession:(id)sender {
    // neu Ray Wenderlich mit NSURLSession und asynchron
    NSLog(@"GPL %s", __PRETTY_FUNCTION__);
    
    self.textView.text = @"";
    
    
    // 1. Erzeugen der NSURLSession
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 2. NSURLSession dataTaskWithURL
    [[session dataTaskWithURL:[NSURL URLWithString:BaseURLString]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                // 4. Fehlerbehandlung bei evtl. aufgetretenem fehler
                if (error) {
                    NSLog(@"Fehler: %@", [error localizedDescription]);
                }
                
                
                NSError* merror;
                // 5. NSArray aus NSData erzeugen
                NSArray* biergartenNSArraAusJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&merror];
                NSLog(@"biergartenNSArraAusJson %@", biergartenNSArraAusJson);
                
                biergartenResponseNSData = data;
                
                // 5. a) Erzeugung eines NSString mit NSData und NSUTF8StringEncoding
                biergartenResponseDataAsString = [[NSString alloc] initWithData:biergartenResponseNSData encoding:NSUTF8StringEncoding];
                
                // 6. Aus einem JSON-String ein NSArray erzeugen
                biergartenResponseDataAsStringJsonObject = [NSJSONSerialization JSONObjectWithData:[biergartenResponseDataAsString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
                
                NSLog(@"biergartenResponseDataAsString = %@", biergartenResponseDataAsString);
                NSLog(@"biergartenResponseDataAsStringJsonObject=%@", biergartenResponseDataAsStringJsonObject);
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.textView.text = [biergartenResponseDataAsStringJsonObject description];
                    
                });
                
            }] resume];

}

- (IBAction)showDispatch_Queue:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.textView.text = @"";
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^{
        [self setBiergartenDataNSURLConnectionSynchronResponse];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSError *error;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:biergartenResponseDataAsStringJsonObject options:NSJSONWritingPrettyPrinted error:&error];
            NSLog(@"jsonData %@", jsonData);
            
            if (error) {
                NSLog(@"Fehler: %@", [error localizedDescription]);
            }
            
            // Aus einem DataAsString ein NSData ermitteln (langer Stile).
            NSData* jsonStringToData = [biergartenResponseDataAsString dataUsingEncoding:NSUTF8StringEncoding];    error = nil;
            NSArray* datenbankAusJson = [NSJSONSerialization JSONObjectWithData:jsonStringToData options:0 error:&error];
            NSLog(@"datenbankAusJson %@", datenbankAusJson);
            
            self.textView.text = [datenbankAusJson description];
            
        });
    });
}

- (IBAction)showAFNetwork:(id)sender {
    // AFHTTPRequestOperationManager
    NSLog(@"%s", __PRETTY_FUNCTION__);
 
    self.textView.text = @"";
    
    /*
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //[manager.requestSerializer setValue:@"calvinAndHobbessRock" forHTTPHeaderField:@"X-I do what I want"];
    
    [manager GET:BaseURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSLog(@"responseObject%@", NSStringFromClass([responseObject class]));
        if([responseObject isKindOfClass:[NSDictionary class]]){
            NSLog(@"responseObject%@", NSStringFromClass([responseObject class]));
            
            NSDictionary *jsonResponseDictionary = responseObject;
            NSLog(@"jsonResponseDictionary = %@", jsonResponseDictionary);
            
            
            // Stringausgabe
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResponseDictionary options:0 error:&error];
            
            if (error) {
                NSLog(@"Fehler: %@", [error localizedDescription]);
            }
            
            NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            NSLog(@"JSONString = %@", JSONString);
            
            
            
            NSData *JSONStringData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
            
            error = nil;
            NSDictionary *myDictionary = [NSJSONSerialization JSONObjectWithData:JSONStringData options:NSJSONReadingMutableContainers error:&error];
            
            if (error) {
                NSLog(@"Fehler: %@", [error localizedDescription]);
            }
            
            NSLog(@"myDictionary = %@", myDictionary);
            
            biergartenResponseDataAsStringJsonObject = [NSJSONSerialization JSONObjectWithData:[biergartenResponseDataAsString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
            self.textView.text = [biergartenResponseDataAsStringJsonObject description];
            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
     */

}
@end
