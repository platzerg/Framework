//
//  SearchViewController.m
//  Foursquare2
//
//  Created by Constantine Fry on 16/02/14.
//
//

#import "SearchViewController.h"
#import "FSVenue.h"
#import "Foursquare2.h"
#import "FSConverter.h"
#import "CheckinViewController.h"

@interface SearchViewController ()
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSArray *venues;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@property (nonatomic, weak) NSOperation *lastSearchOperation;
@property (strong, nonatomic) FSVenue *selected;

@end

@implementation SearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    self.location = newLocation;
    [self startSearchWithString:nil];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self startSearchWithString:searchText];
}

- (void)startSearchWithString:(NSString *)string {
    [self.lastSearchOperation cancel];
    self.lastSearchOperation = [Foursquare2
                                venueSearchNearByLatitude:@(self.location.coordinate.latitude)
                                longitude:@(self.location.coordinate.longitude)
                                query:string
                                limit:nil
                                intent:intentCheckin
                                radius:@(50000000000000)
                                categoryId:nil
                                callback:^(BOOL success, id result){
                                    if (success) {
                                        NSDictionary *dic = result;
                                        NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                        FSConverter *converter = [[FSConverter alloc] init];
                                        self.venues = [converter convertToObjects:venues];
                                        [self.tableView reloadData];
                                    } else {
                                        NSLog(@"%@",result);
                                    }
                                }];
}

- (void)userDidSelectVenue {
    if ([Foursquare2 isAuthorized]) {
        [self checkin];
	} else {
        [Foursquare2 authorizeWithCallback:^(BOOL success, id result) {
            if (success) {
				[Foursquare2  userGetDetail:@"self"
                                   callback:^(BOOL success, id result){
                                       if (success) {
                                           [self checkin];
                                       }
                                   }];
			}
        }];
    }
}

- (void)checkin {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CheckinViewController *checkin = [storyboard instantiateViewControllerWithIdentifier:@"CheckinVC"];
    checkin.venue = self.selected;
    [self.navigationController pushViewController:checkin animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selected = self.venues[indexPath.row];
    [self userDidSelectVenue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.venues[indexPath.row] name];
    return cell;
}

- (IBAction)doneButtonTapped:(id)sender {
    [self.lastSearchOperation cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
