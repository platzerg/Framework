
#import "RegionAnnotation.h"

@interface RegionAnnotation ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@end

@implementation RegionAnnotation

@synthesize region, coordinate, radius;

- (id)init {
	self = [super init];
	if (self != nil) {
		_name = @"Monitored Region";
        _address = @"where";
	}
	
	return self;	
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return [NSString stringWithFormat: @"Lat: %.4F, Lon: %.4F, Rad: %.1fm", coordinate.latitude, coordinate.longitude, radius];
}


- (id)initWithCLRegion:(CLRegion *)newRegion {
	self = [self init];
	
	if (self != nil) {
		self.region = newRegion;
		self.coordinate = region.center;
		self.radius = region.radius;
		_name = @"Monitored Region";
        _address = @"where";
	}		

	return self;		
}


/*
 This method provides a custom setter so that the model is notified when the subtitle value has changed.
 */
- (void)setRadius:(CLLocationDistance)newRadius {
	[self willChangeValueForKey:@"subtitle"];
	
	radius = newRadius;
	
	[self didChangeValueForKey:@"subtitle"];
}


@end
