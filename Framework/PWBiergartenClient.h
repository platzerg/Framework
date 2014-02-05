//
//  PWBiergartenClient.h
//  Framework
//
//  Created by platzerworld on 05.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface PWBiergartenClient : NSObject

- (RACSignal *)fetchJSONFromURL:(NSURL *)url;

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;

@end
