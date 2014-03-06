//
//  PWFBFriedPickerViewController.m
//  Framework
//
//  Created by platzerworld on 05.03.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWFBFriedPickerViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "PWFBPlacePickerViewController.h"

enum SampleFriendSearch {
    SampleFriendSearchHOME
};

@interface PWFBFriedPickerViewController () <FBFriendPickerDelegate, FBPlacePickerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger viewStateSearchScopeIndex;
@property (nonatomic, copy) NSString *viewStateSearchText;
@property (nonatomic) BOOL viewStateSearchWasActive;

@property (retain, nonatomic) NSString *searchText;

- (void)refresh;

@end



@implementation PWFBFriedPickerViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // FBSample logic
    // We are inheriting FBPlacePickerViewController, and so in order to handle events such
    // as selection change, we set our base class' delegate property to self
    self.delegate = self;
    
    /*
     // Set up the additional fields needed
     NSSet *extraFieldsForFriendRequest = [NSSet setWithObjects:@"birthday", @"location", nil];
     // Create a cache descriptor for the additional fields needed
     FBCacheDescriptor *cacheDescriptor = [PWFBFriedPickerViewController
     cacheDescriptorWithUserID:nil
     fieldsForRequest:extraFieldsForFriendRequest];
     // Pre-fetch and cache friend data
     [cacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
     */
    
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
    return NO;
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
        [self searchDisplayController:nil shouldReloadTableForSearchScope:SampleFriendSearchHOME];
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
        case SampleFriendSearchHOME:
            [self updateView];
            break;
    }
    
    
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    self.searchText = searchString;
    [self updateView];
    
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self updateView];
}

- (void)friendPickerViewController:(FBFriendPickerViewController *)friendPicker handleError:(NSError *)error{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user{
    if (self.searchText && ![self.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:self.searchText
                          options:NSCaseInsensitiveSearch];
        if (result.location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
}

- (void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker{
    [self.tableView reloadData];
}


- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker{
    NSLog(@"%s, %@", __PRETTY_FUNCTION__, friendPicker.selection);
    
    // we'll use logging to show the simple typed property access to place and location info
    NSString *infoMessage = [NSString localizedStringWithFormat:@"%@",friendPicker.selection];
    
    // Sample action for place selection completed action
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Friend selected"
                                                        message:infoMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];

}

/*
 * Event: Done button clicked
 */
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    PWFBFriedPickerViewController *friendPickerController = (PWFBFriedPickerViewController*)sender;
    NSLog(@"Selected friends: %@", friendPickerController.selection);
    
    // Dismiss the friend picker
    [[sender presentingViewController] dismissModalViewControllerAnimated:YES];
    
    /*
     [friendPickerController presentModallyFromViewController:self
     animated:YES
     handler:
     ^(FBViewController *sender, BOOL donePressed) {
     if(donePressed) {
     NSLog(@"Selected friends: %@", friendPickerController.selection);
     }
     }];
     */
}

/*
 * Event: Cancel button clicked
 */
- (void)facebookViewControllerCancelWasPressed:(id)sender {
    NSLog(@"Canceled");
    // Dismiss the friend picker
    [[sender presentingViewController] dismissViewControllerAnimated:YES completion:
     ^(void)
     {
         NSLog(@"%s", __PRETTY_FUNCTION__);
     }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLocationForFriend"]) {
        PWFBPlacePickerViewController *placePickerController = (PWFBPlacePickerViewController *) segue.destinationViewController;        placePickerController.locationCoordinate = CLLocationCoordinate2DMake(48.179796, 11.592184);
        placePickerController.radiusInMeters = 1000;
        placePickerController.resultsLimit = 20;
        [placePickerController loadData];
    }
}

@end
