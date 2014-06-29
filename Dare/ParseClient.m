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
                NSMutableArray *messages = [objects mutableCopy];
                
                PFFile *imageFile = currentUser[@"image"];
                UIImage *userPic = [self imageFileToImage:imageFile];
                
                User *loggedUser = [[User alloc]initWithDisplayName:currentUser[@"displayName"]
                                         messageThreads:messageThreads //PFObjects
                                                friends:friends //PFObjects
                                               messages:messages
                                            identifier:currentUser[@"objectId"]
                                            profileImage:userPic];
                completion(loggedUser);
                
            }];
        }];
    }];
}


+ (UIImage *)imageFileToImage: (PFFile *)imageFile
{
    NSData *imageData = [imageFile getData];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}


+ (void)loginWithFB: (void(^)())completion
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
                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        PFUser *currentUser = [PFUser currentUser];
                        [currentUser setObject:[result objectForKey:@"id"] forKey:@"fbId"];
                        [currentUser setObject:[result objectForKey:@"name"] forKey:@"displayName"];
                        [currentUser saveInBackground];
                        // Store the current user's Facebook ID, userName and photo on the user
                        [self fetchUserProfilePicture:^(NSData *imageData) { //if fails should handle offer to take a picture from camera of device library
                            
                            PFFile *file = [PFFile fileWithName:@"userPic" data:imageData];
                            [file saveInBackground];
                            [currentUser setObject:file forKey:@"image"];
                            [currentUser saveInBackground];
                            
                            completion();
                        }];
                    }
                }];
            } else {
                
                NSLog(@"Existing user logged in through Facebook!");
                //completion();
            }
        }];
    }
}

+ (void)fetchUserProfilePicture: (void(^)(NSData *))completion
{
    NSString *requestPath = @"me/?fields=picture.type(large)";
    FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:requestPath];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (result) {
            NSString *urlString = result[@"picture"][@"data"][@"url"];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString: urlString]];
            completion(imageData);
        } else {
            NSLog(@"%@", error);
        }  
    }];
}

+ (void)getMessageThreadsForUser: (User *)user
                     completion: (void(^)(NSArray *, bool))completion
                     failure: (void(^)())failure
{
    NSMutableArray *userThreads = [[NSMutableArray alloc]init];
    __block NSInteger count = 0;
    
    
    for (PFObject *parseThread in user.messageThreads) {

        PFRelation *participantsRelation = [parseThread relationForKey:@"User"];
        PFQuery *participantsQuery = [participantsRelation query];
        
        
        [participantsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray *participants = objects;
            
            MessageThread *thread = [[MessageThread alloc]initWithUser:user
                                                          participants:participants
                                                              messages:user.messages
                                                            identifier:[parseThread objectId]];
            [userThreads addObject:thread];
            count++;
            
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
                    BOOL isRead = NO;
                    if (![parseMessage[@"isRead"] isEqualToString:@"NO"]) {
                        isRead = YES;
                    }
                    Message *message = [[Message alloc]initWithText:parseMessage[@"text"]
                                                               user: user
                                                             thread:thread
                                                             isRead:isRead];
                    [threadMessages addObject:message];
                }
                completion(threadMessages);
            }];

        } else {
            failure(error);
        }
            }];
}

+ (void)addMessageToThread: (MessageThread *)thread
                  withText: (NSString *)text
                   picture: (NSString *)pictureString
{
    PFQuery *threadQuery = [PFQuery queryWithClassName:@"MessageThread"];
    [threadQuery whereKey:@"id" equalTo:thread.identifier];
    [threadQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *parseThread = objects[0];
        
        PFObject *parseMessage = [PFObject objectWithClassName:@"Message"];
        [parseMessage addObject:text forKey:@"text"];
        [parseMessage addObject:pictureString forKey:@"picture"];
        [parseMessage addObject:@"NO" forKey:@"isRead"];
        
        PFRelation *messageToThread = [parseMessage relationForKey:@"messageThreads"];
        [messageToThread addObject:parseThread];
        [parseMessage saveInBackground];
        PFRelation *threadToMessage = [parseThread relationForKey:@"messages"];
        [threadToMessage addObject:parseMessage];
        [parseThread saveInBackground];
    }];
}



+ (void)findUserByName: (NSString *)displayName
            completion:(void(^)(User *))completion
{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"displayName" equalTo:displayName];
    NSArray *foundUsers = [userQuery findObjects];
    if ([foundUsers count] > 0) {
        PFUser *foundUser = foundUsers[0];
        [self getUser:foundUser completion:^(User *searchResultUser) {
            //NSLog(@"Search result user: %@", searchResultUser.displayName);
            completion(searchResultUser);
        } failure:nil];
    } else {
        completion(nil);
    }
}

+ (void)findPFUserByName: (NSString *)displayName
                  completion:(void(^)(PFUser *))completion
{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"displayName" equalTo:displayName];
    NSArray *foundUsers = [userQuery findObjects];
    if ([foundUsers count] > 0) {
        PFUser *foundUser = foundUsers[0];
        completion(foundUser);
    } else {
        completion(nil);
    }
}

+ (void)findPFUserByFacebookId: (NSString *)fbid
                    completion:(void(^)(PFUser *))completion
{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"fbId" equalTo:fbid];
    NSArray *foundUsers = [userQuery findObjects];
    if ([foundUsers count] > 0) {
        PFUser *foundUser = foundUsers[0];
        completion(foundUser);
    } else {
        completion(nil);
    }
}


+ (void)relateFriend: (PFUser *)friend
       completion:(void(^)())completion//adds PFUser to friends relation
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        PFRelation *friendRelation = [currentUser relationForKey:@"friends"];
        [friendRelation addObject:friend];
        [currentUser saveInBackground];
        completion();
    } else {
        NSLog(@"not logged in");
    }
}

+ (void)relateFacebookFriendsInParse: (void(^)(bool))completion
                             failure: (void(^)(NSError *))failure //adds friend relation with FBFriends, who already have logged in to Parse
{
    FBRequest *friendsRequest = [[FBRequest alloc]initWithSession:[PFFacebookUtils session] graphPath:@"me/friends"];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSArray *data = [result objectForKey:@"data"];
            __block NSInteger count = 0;
            if (data) {
                for (NSMutableDictionary *friendData in data) {
                    
                    [self findPFUserByFacebookId:friendData[@"id"] completion:^(PFUser *foundUser) {
                        [self relateFriend:foundUser completion:^{
                            count++;
                        }];
                    }];
                }
            }
            bool isDone = NO;
            if (count == [data count]) {
                isDone = YES;
            }
            completion(isDone);
        } else {
            failure(error);
        }
    }];
}




@end
