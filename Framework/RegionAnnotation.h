
#import <MapKit/MapKit.h>

@interface RegionAnnotation : NSObject <MKAnnotation> {

}

@property (nonatomic, retain) CLRegion *region;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite) CLLocationDistance radius;

- (id)initWithCLRegion:(CLRegion *)newRegion;

@end
