//
//  ParseClient.m
//  Dare
//
//  Created by Dare Ryan on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "ParseClient.h"

@implementation ParseClient

+ (void)loginUser: (NSString *)userName
       completion: (void(^)(NSString *))completion
          failure: (void(^)())failure
{
    [PFUser logInWithUsernameInBackground:userName password:@"" block:^(PFUser *user, NSError *error) {
        if (user) {
            NSString *displayName = [user objectForKey:@"displayName"];
            completion(displayName);
        } else {
            failure();
        }
    }];
}

+ (void)getLoggedInUser: (void(^)(User *))completion
            WithFailure: (void(^)())failure
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        PFRelation *messageThreadRelation = [currentUser relationForKey:@"messageThreads"];
        PFRelation *friendsRelation = [currentUser relationForKey:@"friends"];
        PFRelation *messagesRelation = [currentUser relationForKey:@"messages"];
        
        PFQuery *messageThreadQuery = [messageThreadRelation query]; //config to limit amount of queries
        PFQuery *friendsQuery = [friendsRelation query];
        PFQuery *messagesQuery =[messagesRelation query];
        
        [messageThreadQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray *messageThreads = objects;
            [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSArray *friends = objects;
                [messagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    NSArray *messages = objects;
                    User *loggedUser = [[User alloc]initWithDisplayName:currentUser[@"displayName"]
                                             messageThreads:messageThreads //PFObjects
                                                    friends:friends //PFObjects
                                                   messages:messages]; //PFObjects
                    completion(loggedUser);
                }];
            }];
        }];
    } else {
        failure();
    }
}


+ (void)loginWithFB
{
    [PFFacebookUtils initializeFacebook];
    NSArray *permissions = @[@"email", @"user_friends"];
    if (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded) {
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
            if (!user) {
                if (!error) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                }
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
            } else {
                NSLog(@"User logged in through Facebook!");
                NSLog(@"Currently loggen in: %@", [PFUser currentUser]);
            }
        }];
    }
}



@end
