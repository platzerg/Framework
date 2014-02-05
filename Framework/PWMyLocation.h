//
//  PWMyLocation.h
//  Framework
//
//  Created by platzerworld on 02.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "PWBiergarten.h"


@interface PWMyLocation : NSObject <MKAnnotation>

@property (nonatomic, strong) PWBiergarten *biergarten;

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;

@end