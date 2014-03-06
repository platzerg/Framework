//
//  PWFBPlacePickerViewController.m
//  Framework
//
//  Created by platzerworld on 05.03.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWFBPlacePickerViewController.h"

enum SampleLocation {
    SampleLocationHOME,
    SampleLocationGPS,
};

@interface PWFBPlacePickerViewController () <CLLocationManagerDelegate, FBPlacePickerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger viewStateSearchScopeIndex;
@property (nonatomic, copy) NSString *viewStateSearchText;
@property (nonatomic) BOOL viewStateSearchWasActive;

- (void)refresh;
@end

@implementation PWFBPlacePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // FBSample logic
    // We are inheriting FBPlacePickerViewController, and so in order to handle events such
    // as selection change, we set our base class' delegate property to self
    self.delegate = self;
    
    self.searchDisplayController.searchResultsDataSource = self.tableView.dataSource;
    self.searchDisplayController.searchResultsDelegate = self.tableView.delegate;
    
    if (self.viewStateSearchText) {
        [self.searchDisplayController.searchBar
         setSelectedScopeButtonIndex:self.viewStateSearchScopeIndex];
        [self.searchDisplayController.searchBar setText:self.viewStateSearchText];
        [self.searchDisplayController setActive:self.viewStateSearchWasActive];
        
        self.viewStateSearchText = nil;
    }    
    [self refresh];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.viewStateSearchScopeIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    self.viewStateSearchText = [self.searchDisplayController.searchBar text];
    self.viewStateSearchWasActive = [self.searchDisplayController isActive];
}

- (void)placePickerViewControllerDataDidChange:(FBPlacePickerViewController *)placePicker {
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Location Manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (newLocation.horizontalAccuracy < 100) {
        // We wait for a precision of 100m and turn the GPS off
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
        
        self.locationCoordinate = newLocation.coordinate;
        [self loadData];
    }
}

#pragma mark - UISearchBarDelegate Methods
// Just set the search string to an empty string and inform
// the delegate (self) to reload data
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchText = @"";
    [self loadData];
}

// FBSample logic
// This method is responsible for keeping UX and session state in sync
- (void)refresh {
    // if the session is open, then load the data for our view controller
    if (FBSession.activeSession.isOpen) {
        // Default to Seattle, this method calls loadData
        [self searchDisplayController:nil shouldReloadTableForSearchScope:SampleLocationHOME];
    } else {
        // if the session isn't open, we open it here, which may cause UX to log in the user
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (!error) {
                                              [self refresh];
                                          } else {
                                              [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                          message:error.localizedDescription
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil]
                                               show];
                                          }
                                      }];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    switch (searchOption) {
        case SampleLocationHOME:
            // FBSample logic
            // After setting the coordinates for the data we wish to fetch, we call loadData to initiate
            // the actual network round-trip with Facebook; likewise for the other two locations
            // 48.179796, 11.592184
            self.locationCoordinate = CLLocationCoordinate2DMake(48.179796, 11.592184);
            [self loadData];
            break;
        case SampleLocationGPS:
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            [self.locationManager startUpdatingLocation];
            break;
    }
    
    // When startUpdatingLocation/loadData finish, we will reload then.
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // FBSample logic
    // When search text changes, we update the property on our base class, and then refetch data; the
    // Scrumptious sample shows a more complex implementation of this, where frequent updates are aggregated,
    // and fetching happens on a timed basis to avoid becomming to chatty with the server; this sample takes
    // a more simplistic approach
    self.searchText = searchString;
    [self loadData];
    
    // Setting self.searchText will reload the table when results arrive
    return NO;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.tableView reloadData];
}

- (void)placePickerViewControllerSelectionDidChange:(FBPlacePickerViewController *)placePicker
{
    // FBSample logic
    // Here we see a use of the FBGraphPlace protocol, where our code can use dot-notation to
    // select name and location data from the selected place
    id<FBGraphPlace> place = placePicker.selection;
    
    // Make sure that we don't show message when the same row is being clicked twice (to be deselected)
    if(!place) {
        return;
    }
    
    // we'll use logging to show the simple typed property access to place and location info
    NSString *infoMessage = [NSString localizedStringWithFormat:@"place=%@\n city=%@, state=%@\n lat=%@\n long=%@\n",
                             place.name,
                             place.location.city,
                             place.location.state,
                             place.location.latitude,
                             place.location.longitude];
    
    NSLog(@"%@", infoMessage);
    NSLog(@"%@", place);
    
    // Sample action for place selection completed action
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Place selected"
                                                        message:infoMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


@end
