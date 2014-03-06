//
//  PWFBFQLViewController.m
//  Framework
//
//  Created by platzerworld on 06.03.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWFBFQLViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PWFBFriedPickerViewController.h"

@interface PWFBFQLViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *queryButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *multiQueryButton;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textView;
@end

@implementation PWFBFQLViewController
@synthesize queryButton;
@synthesize multiQueryButton;



/*
 * Present the friend details display view controller
 */
- (void) showFriends:(NSArray *)friendData
{
    self.data = friendData;
    
    NSLog(@"%@",friendData);
    
    self.textView.text = [NSString stringWithFormat:@"%@",friendData ];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	

}

- (void)viewDidUnload
{
    [self setQueryButton:nil];
    [self setMultiQueryButton:nil];    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


#pragma mark - Action methods
- (IBAction)queryButtonAction:(id)sender {
    self.textView.text = @"";
    // Query to fetch the active user's friends, limit to 25.
    NSString *query =
    @"SELECT uid, name, pic_square FROM user WHERE uid IN "
    @"(SELECT uid2 FROM friend WHERE uid1 = me() LIMIT 25)";
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Result: %@", result);
                                  // Get the friend data to display
                                  NSArray *friendInfo = (NSArray *) result[@"data"];
                                  // Show the friend details display
                                  [self showFriends:friendInfo];
                              }
                          }];
}

- (IBAction)multiQueryButtonAction:(id)sender {
    self.textView.text = @"";
    // Multi-query to fetch the active user's friends, limit to 25.
    // The initial query is stored in reference named "friends".
    // The second query picks up the "uid2" info from the first
    // query and gets the friend details.
    NSString *query =
    @"{"
    @"'friends':'SELECT uid2 FROM friend WHERE uid1 = me() LIMIT 25',"
    @"'friendinfo':'SELECT uid, name, pic_square FROM user WHERE uid IN (SELECT uid2 FROM #friends)',"
    @"}";
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Result: %@", result);
                                  // Get the friend data to display
                                  NSArray *friendInfo =
                                  (NSArray *) result[@"data"][1][@"fql_result_set"];
                                  // Show the friend details display
                                  [self showFriends:friendInfo];
                              }
                          }];
}
@end
