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

+ (void)getUser: (PFUser *)currentUser
     completion:(void(^)(User *))completion
            failure: (void(^)())failure
{
    //PFUser *currentUser = [PFUser currentUser];
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
                NSArray *messages = [objects mutableCopy];
                User *loggedUser = [[User alloc]initWithDisplayName:currentUser[@"displayName"]
                                         messageThreads:messageThreads //PFObjects
                                                friends:friends //PFObjects
                                               messages:messages
                                            identifier:currentUser[@"objectId"]]; //PFObjects
                completion(loggedUser);
                
            }];
        }];
    }];
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

+ (void)getMessageThreadsForUser: (User *)user
                     completion: (void(^)(NSArray *, bool))completion
                     failure: (void(^)())failure
{
    NSMutableArray *userThreads = [[NSMutableArray alloc]init];
    NSInteger count = 0;
    
    for (PFObject *parseThread in user.messageThreads) {

        PFRelation *participantsRelation = [parseThread relationForKey:@"User"];
        PFQuery *participantsQuery = [participantsRelation query];
        count++;
        
        [participantsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray *participants = objects;
            
            MessageThread *thread = [[MessageThread alloc]initWithUser:user
                                                          participants:participants
                                                              messages:user.messages
                                                            identifier:[parseThread objectId]];
            [userThreads addObject:thread];
            
            bool isDone = NO;
            if (count == [user.messageThreads count]) {
                isDone = YES;
            }
            
            completion(userThreads, isDone);
        }];
    }
}

+ (void)getMessagesForThread: (MessageThread *)thread
                     user: (User *)user
                completion: (void(^)(NSArray *))completion
                   failure: (void(^)(NSError *))failure
{
    NSMutableArray *threadMessages = [[NSMutableArray alloc]init];
        
    PFQuery *threadQueryOnId = [PFQuery queryWithClassName:@"MessageThread"];
    [threadQueryOnId whereKey:@"objectId" equalTo:thread.identifier];
    [threadQueryOnId findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFObject *parseThread = objects[0];
            PFRelation *threadRelation = [parseThread relationForKey:@"messages"];
            PFQuery *threadQuery = [threadRelation query];
            
            [threadQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSArray *parseMessages = objects;
                for (PFObject *parseMessage in parseMessages) {
                    Message *message = [[Message alloc]initWithText:parseMessage[@"text"]
                                                               user: user
                                                             thread:thread];
                    [threadMessages addObject:message];
                }
                completion(threadMessages);
            }];

        } else {
            failure(error);
        }
            }];
}


+ (void)findUserByName: (NSString *)displayName
            completion:(void(^)(User *))completion
{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"displayName" equalTo:displayName];
    PFUser *foundUser = [userQuery findObjects][0];
    
    [self getUser:foundUser completion:^(User *searchResultUser) {
        //NSLog(@"Search result user: %@", searchResultUser.displayName);
        completion(searchResultUser);
    } failure:nil];
}




@end
