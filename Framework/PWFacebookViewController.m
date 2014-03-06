//
//  PWFacebookViewController.m
//  Framework
//
//  Created by platzerworld on 04.03.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//
//  https://developers.facebook.com/docs/facebook-login/testing-your-login-flow/
//

#import "PWFacebookViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "PWAppDelegate.h"
#import "PWFBPlacePickerViewController.h"
#import "PWFBFriedPickerViewController.h"
#import <Social/Social.h>

@interface PWFacebookViewController () <FBLoginViewDelegate>

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostStatus;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostPhoto;
@property (strong, nonatomic) IBOutlet UIButton *buttonPickFriends;
@property (strong, nonatomic) IBOutlet UIButton *buttonPickPlace;
@property (strong, nonatomic) IBOutlet UILabel *labelFirstName;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@property (readwrite, copy, nonatomic) NSSet *extraFieldsForFriendRequest;
@property (assign, nonatomic) CLLocationCoordinate2D searchLocation;

- (IBAction)postStatusUpdateClick:(UIButton *)sender;
- (IBAction)postPhotoClick:(UIButton *)sender;
- (IBAction)pickFriendsClick:(UIButton *)sender;
- (IBAction)pickPlaceClick:(UIButton *)sender;

- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error;


@end


@implementation PWFacebookViewController
{
    NSURL *urlToShare;
    FBFriendPickerViewController *friendPickerController;
    FBPlacePickerViewController *placePickerController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    urlToShare = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
    // Create Login View so that the app will be granted "status_update" permission.
    FBLoginView *loginView = [[FBLoginView alloc] init];
    self.searchLocation = CLLocationCoordinate2DMake(48.179796, 11.592184);
    
    NSArray *permissions = [NSArray arrayWithObjects:
                            @"status_update",
                            @"friends_photos",
                            @"user_photos",
                            @"user_birthday",
                            @"read_stream",
                            @"publish_stream",
                            nil];
    
    loginView.readPermissions = @[@"basic_info", @"email", @"user_likes", @"user_birthday", @"user_location"];
    
    // Align the button in the center horizontally
    
    loginView.frame = CGRectOffset(loginView.frame, 5, 60);
    
    loginView.delegate = self;
    
    [self.view addSubview:loginView];
    
    [loginView sizeToFit];
}

- (void)viewDidUnload {
    self.buttonPickFriends = nil;
    self.buttonPickPlace = nil;
    self.buttonPostPhoto = nil;
    self.buttonPostStatus = nil;
    self.labelFirstName = nil;
    self.loggedInUser = nil;
    self.profilePic = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - FBLoginViewDelegate

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    self.labelFirstName.text = [NSString stringWithFormat:@"%@ : Hallo %@ %@!",user.id, user.first_name, user.last_name];
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    self.profilePic.profileID = user.id;
    self.loggedInUser = user;
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // first get the buttons set for login mode
    self.buttonPostPhoto.enabled = YES;
    self.buttonPostStatus.enabled = YES;
    self.buttonPickFriends.enabled = YES;
    self.buttonPickPlace.enabled = YES;
    
    // "Post Status" available when logged on and potentially when logged off.  Differentiate in the label.
    [self.buttonPostStatus setTitle:@"Post Status Update (Logged On)" forState:self.buttonPostStatus.state];
    
    
    
    // Cache friend data
    FBCacheDescriptor  *friendCacheDescriptor = [PWFBFriedPickerViewController
                                                 cacheDescriptorWithUserID:nil
                                                 fieldsForRequest:self.extraFieldsForFriendRequest];
    [friendCacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
    
    // Cache nearby place data
    FBCacheDescriptor *placeCacheDescriptor =
    [PWFBPlacePickerViewController
     cacheDescriptorWithLocationCoordinate:self.searchLocation
     radiusInMeters:1000
     searchText:nil
     resultsLimit:20
     fieldsForRequest:nil];
    [placeCacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // test to see if we can use the share dialog built into the Facebook application
    FBShareDialogParams *p = [[FBShareDialogParams alloc] init];
    p.link = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
#ifdef DEBUG
    [FBSettings enableBetaFeatures:FBBetaFeaturesShareDialog];
#endif
    BOOL canShareFB = [FBDialogs canPresentShareDialogWithParams:p];
    BOOL canShareiOS6 = [FBDialogs canPresentOSIntegratedShareDialogWithSession:nil];
    
    self.buttonPostStatus.enabled = canShareFB || canShareiOS6;
    self.buttonPostPhoto.enabled = NO;
    self.buttonPickFriends.enabled = NO;
    self.buttonPickPlace.enabled = NO;
    
    // "Post Status" available when logged on and potentially when logged off.  Differentiate in the label.
    [self.buttonPostStatus setTitle:@"Post Status Update (Logged Off)" forState:self.buttonPostStatus.state];
    
    self.profilePic.profileID = nil;
    self.labelFirstName.text = nil;
    self.loggedInUser = nil;
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSLog(@"FBLoginView encountered an error=%@", error);
    NSString *alertMessage, *alertTitle;
    
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage
                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}



#pragma mark -
- (void)performPublishAction:(void(^)(void))action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
           defaultAudience:FBSessionDefaultAudienceFriends
           completionHandler:^(FBSession *session, NSError *error) {
               if (!error) {
                  action();
               } else if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                    message:@"Unable to get permission to post" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alertView show];
               }
        }];
    } else {
        action();
    }
    
}

- (IBAction)postStatusUpdateClick:(UIButton *)sender {    
    SLComposeViewController *slc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [slc addImage: [UIImage imageNamed:@"arrest.png"]];
    [slc addURL: [NSURL URLWithString:@"http://apple.com"]];
    [self presentViewController:slc animated:YES completion:NULL];
    
}

// Post Photo button handler
- (IBAction)postPhotoClick:(UIButton *)sender {
    // Just use the icon image from the application itself.  A real app would have a more
    // useful way to get an image.
    UIImage *img = [UIImage imageNamed:@"Icon-72@2x.png"];
    
    [self performPublishAction:^{
        FBRequestConnection *connection = [[FBRequestConnection alloc] init];
        connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
        | FBRequestConnectionErrorBehaviorAlertUser
        | FBRequestConnectionErrorBehaviorRetry;
        
        [connection addRequest:[FBRequest requestForUploadPhoto:img]
             completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                 [self showAlert:@"Photo Post" result:result error:error];
                 if (FBSession.activeSession.isOpen) {
                     self.buttonPostPhoto.enabled = YES;
                 }
             }];
        [connection start];
        
        self.buttonPostPhoto.enabled = NO;
    }];
}

// Pick Friends button handler
- (IBAction)pickFriendsClick:(UIButton *)sender {
    friendPickerController = [[FBFriendPickerViewController alloc] init];
    friendPickerController.title = @"Pick Friends";
    [friendPickerController loadData];
    
    // Use the modal wrapper method to display the picker.
    [friendPickerController presentModallyFromViewController:self animated:YES handler:
     ^(FBViewController *innerSender, BOOL donePressed) {
         if (!donePressed) {
             return;
         }
         
         NSString *message;
         
         if (friendPickerController.selection.count == 0) {
             message = @"<No Friends Selected>";
         } else {
             
             NSMutableString *text = [[NSMutableString alloc] init];
             
             // we pick up the users from the selection, and create a string that we use to update the text view
             // at the bottom of the display; note that self.selection is a property inherited from our base class
             for (id<FBGraphUser> user in friendPickerController.selection) {
                 if ([text length]) {
                     [text appendString:@", "];
                 }
                 [text appendString:user.name];
             }
             message = text;
         }
         
         [[[UIAlertView alloc] initWithTitle:@"You Picked:"
                                     message:message
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]
          show];
     }];
}

// Pick Place button handler
- (IBAction)pickPlaceClick:(UIButton *)sender {
    placePickerController = [[FBPlacePickerViewController alloc] init];
    placePickerController.title = @"Pick a Seattle Place";
    placePickerController.locationCoordinate = CLLocationCoordinate2DMake(48.179796, 11.592184);
    [placePickerController loadData];
    
    // Use the modal wrapper method to display the picker.
    [placePickerController presentModallyFromViewController:self animated:YES handler:
     ^(FBViewController *innerSender, BOOL donePressed) {
         if (!donePressed) {
             return;
         }
         
         NSString *placeName = placePickerController.selection.name;
         if (!placeName) {
             placeName = @"<No Place Selected>";
         }
         
         [[[UIAlertView alloc] initWithTitle:@"You Picked:"
                                     message:placeName
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]
          show];
     }];
}

// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message result:(id)result error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertTitle = @"Error";
        // Since we use FBRequestConnectionErrorBehaviorAlertUser,
        // we do not need to surface our own alert view if there is an
        // an fberrorUserMessage unless the session is closed.
        if (error.fberrorUserMessage && FBSession.activeSession.isOpen) {
            alertTitle = nil;
            
        } else {
            // Otherwise, use a general "connection problem" message.
            alertMsg = @"Operation failed due to a connection problem, retry later.";
        }
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.", message];
        NSString *postId = [resultDict valueForKey:@"id"];
        if (!postId) {
            postId = [resultDict valueForKey:@"postId"];
        }
        if (postId) {
            alertMsg = [NSString stringWithFormat:@"%@\nPost ID: %@", alertMsg, postId];
        }
        alertTitle = @"Success";
    }
    
    if (alertTitle) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)doPost1:(id)sender {
    // 1. Mit Facebook App
    FBAppCall *appCall = [FBDialogs presentShareDialogWithLink:urlToShare
              name:@"Hello Facebook" caption:nil
              description:@"The 'Hello Facebook' sample application showcases simple Facebook integration."
              picture:nil clientState:nil
              handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
               if (error) {
                   NSLog(@"Error: %@", error.description);
               } else {
                   NSLog(@"Success!");
               }
    }];
    [appCall debugDescription];
}

- (IBAction)doPost2:(id)sender {
    [FBDialogs presentOSIntegratedShareDialogModallyFrom:self initialText:nil image:nil url:urlToShare handler:nil];
}

- (IBAction)doPost3:(id)sender {
    [self performPublishAction:^{
        NSString *message = [NSString stringWithFormat:@"Updating status for %@ at %@", self.loggedInUser.first_name, [NSDate date]];
        
        FBRequestConnection *connection = [[FBRequestConnection alloc] init];
        
        connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
        | FBRequestConnectionErrorBehaviorAlertUser
        | FBRequestConnectionErrorBehaviorRetry;
        
        [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
             completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                 [self showAlert:message result:result error:error];
                 self.buttonPostStatus.enabled = YES;
             }];
        [connection start];
        
        self.buttonPostStatus.enabled = NO;
    }];

}

- (IBAction)doShareLinkWithShareDialog:(id)sender {
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    params.name = @"Sharing Tutorial";
    params.caption = @"Build great social apps and get more installs.";
    params.picture = [NSURL URLWithString:@"http://i.imgur.com/g3Qc1HN.png"];
    params.description = @"Allow your users to share stories on Facebook from your app using the iOS SDK.";
    
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
            name:params.name
            caption:params.caption
            description:params.description
            picture:params.picture
            clientState:nil
            handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
              if(error) {
                  NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
              } else {
                  // Success
                  NSLog(@"result %@", results);
              }
          }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Sharing Tutorial", @"name",
                                       @"Build great social apps and get more installs.", @"caption",
                                       @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                       @"https://developers.facebook.com/docs/ios/share/", @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
        parameters:params
          handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
              if (error) {
                  NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
              } else {
                  if (result == FBWebDialogResultDialogNotCompleted) {
                      // User canceled.
                      NSLog(@"User cancelled.");
                  } else {
                      // Handle the publish feed callback
                      NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                      
                      if (![urlParams valueForKey:@"post_id"]) {
                          // User canceled.
                          NSLog(@"User cancelled.");
                          
                      } else {
                          // User clicked the Share button
                          NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                          NSLog(@"result %@", result);
                      }
                  }
              }
          }];
    }
}

- (IBAction)doPostStatusUpdateWithShareDialog:(id)sender {
    // Check if the Facebook app is installed and we can present the share dialog
    
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:nil
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

- (IBAction)doShareLinkWithAPICalls:(id)sender {
    // We will post on behalf of the user, these are the permissions we need:
    NSArray *permissionsNeeded = @[@"publish_actions"];
    NSArray *permissions = [NSArray arrayWithObjects:
                            @"status_update",
                            @"friends_photos",
                            @"user_photos",
                            @"user_birthday",
                            @"read_stream",
                            @"publish_stream",
                            nil];

    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
      completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
          if (!error){
              NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
              NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
              
              // Check if all the permissions we need are present in the user's current permissions
              // If they are not present add them to the permissions to be requested
              for (NSString *permission in permissionsNeeded){
                  if (![currentPermissions objectForKey:permission]){
                      [requestPermissions addObject:permission];
                  }
              }
              
              // If we have permissions to request
              if ([requestPermissions count] > 0){
                  // Ask for the missing permissions
                  [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                        defaultAudience:FBSessionDefaultAudienceFriends
                                                      completionHandler:^(FBSession *session, NSError *error) {
                                                          if (!error) {
                                                              [self makeRequestToShareLink];
                                                          } else {
                                                              NSLog([NSString stringWithFormat:@"%@", error.description]);
                                                          }
                                                      }];
              } else {
                  // Permissions are present, we can request the user information
                  [self makeRequestToShareLink];
              }
              
          } else {
              // There was an error requesting the permission information
              // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
              NSLog([NSString stringWithFormat:@"%@", error.description]);
          }
      }];

}



- (IBAction)doStatusUpdateWithAPICalls:(id)sender {
    // We will post on behalf of the user, these are the permissions we need:
    NSArray *permissionsNeeded = @[@"publish_actions"];
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
      completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
          if (!error){
              NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
              NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
              
              // Check if all the permissions we need are present in the user's current permissions
              // If they are not present add them to the permissions to be requested
              for (NSString *permission in permissionsNeeded){
                  if (![currentPermissions objectForKey:permission]){
                      [requestPermissions addObject:permission];
                  }
              }
              
              // If we have permissions to request
              if ([requestPermissions count] > 0){
                  // Ask for the missing permissions
                  [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                        defaultAudience:FBSessionDefaultAudienceFriends
                                                      completionHandler:^(FBSession *session, NSError *error) {
                                                          if (!error) {
                                                              // Permission granted, we can request the user information
                                                              [self makeRequestToUpdateStatus];
                                                          } else {
                                                              // An error occurred, handle the error
                                                              // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                              NSLog([NSString stringWithFormat:@"%@", error.description]);
                                                          }
                                                      }];
              } else {
                  // Permissions are present, we can request the user information
                  [self makeRequestToUpdateStatus];
              }
              
          } else {
              // There was an error requesting the permission information
              // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
              NSLog([NSString stringWithFormat:@"%@", error.description]);
          }
      }];
}
- (void)makeRequestToShareLink {
    
    // NOTE: pre-filling fields associated with Facebook posts,
    // unless the user manually generated the content earlier in the workflow of your app,
    // can be against the Platform policies: https://developers.facebook.com/policy
    
    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Sharing Tutorial", @"name",
                                   @"Build great social apps and get more installs.", @"caption",
                                   @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                   @"https://developers.facebook.com/docs/ios/share/", @"link",
                                   @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                   nil];
    
    // Make the request
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  NSLog([NSString stringWithFormat:@"result: %@", result]);
                              } else {
                                  NSLog([NSString stringWithFormat:@"%@", error.description]);
                              }
                          }];
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
- (void)makeRequestToUpdateStatus {
    
    // NOTE: pre-filling fields associated with Facebook posts,
    // unless the user manually generated the content earlier in the workflow of your app,
    // can be against the Platform policies: https://developers.facebook.com/policy
    
    [FBRequestConnection startForPostStatusUpdate:@"User-generated status update."
    completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog([NSString stringWithFormat:@"result: %@", result]);
        } else {
            NSLog([NSString stringWithFormat:@"%@", error.description]);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"fbfriendpicker"]) {
        PWFBFriedPickerViewController *friendPickerController = (PWFBFriedPickerViewController *) segue.destinationViewController;
        
        friendPickerController.title = @"PW Pick Friends";
        // Allow the selection of only one friend
        friendPickerController.allowsMultipleSelection = YES;
        
        // Hide the friend profile pictures
        friendPickerController.itemPicturesEnabled = YES;
        
        // Configure how friends are sorted in the display.
        // Sort friends by their last names.
        friendPickerController.sortOrdering = FBFriendSortByLastName;
        
        // Configure how each friend's name is displayed.
        // Display the last name first.
        friendPickerController.displayOrdering = FBFriendDisplayByLastName;
        
        // Hide the done button
        //friendPickerController.doneButton = nil;
        
        // Hide the cancel button
        friendPickerController.cancelButton = nil;
        
        // Get friend's list from one of user's friends.
        // Hard-coded for now.
        //friendPickerController.userID = @"100003086810435";
        
        
        
        [friendPickerController loadData];
    }
}

@end
