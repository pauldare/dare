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
       completion: (void(^)())completion
          failure: (void(^)())failure
{
    [PFUser logInWithUsernameInBackground:userName password:@"" block:^(PFUser *user, NSError *error) {
        if (user) {
            [self getUser:user completion:^(User *user) {
                NSLog(@"%@", user.displayName);
                completion();
            } failure:nil];
        } else {
            failure();
        }
    }];
}

+ (void)getUser: (PFUser *)currentUser
     completion:(void(^)(User *))completion
            failure: (void(^)())failure
{
    PFRelation *friendsRelation = [currentUser relationForKey:@"friends"];
    PFRelation *messagesRelation = [currentUser relationForKey:@"messages"];
    PFQuery *friendsQuery = [friendsRelation query];
    PFQuery *messagesQuery =[messagesRelation query];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray *friends = objects;
        [messagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray *messages = [objects mutableCopy];
            PFFile *imageFile = currentUser[@"image"];
            UIImage *userPic = [self imageFileToImage:imageFile];
            User *loggedUser = [[User alloc]initWithDisplayName:currentUser[@"displayName"]
                                                        friends:friends //PFObjects
                                                       messages:messages
                                                     identifier:currentUser[@"fbId"]
                                                   profileImage:userPic];
            completion(loggedUser);
        }];
    }];
}


+ (UIImage *)imageFileToImage: (PFFile *)imageFile
{
    NSData *imageData = [imageFile getData];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}


+ (void)loginWithFB: (void(^)(BOOL))completion
{
    [PFFacebookUtils initializeFacebook];
    NSArray *permissions = @[@"email", @"user_friends"];
    __block BOOL isNEW = NO;
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
                            isNEW = YES;
                            completion(isNEW);
                        }];
                    }
                }];
            } else {
                NSLog(@"Existing user logged in through Facebook!");
                completion(isNEW);
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
    PFQuery *userQuery = [PFQuery queryWithClassName:@"UserProxy"];
    [userQuery whereKey:@"identifier" equalTo:user.identifier];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] != 0) {
            PFObject *userProxy = objects[0];
            for (PFObject *parseThread in userProxy[@"threads"]) {
                PFRelation *participantsRelation = [parseThread relationForKey:@"Users"];
                PFQuery *participantsQuery = [participantsRelation query];
                [participantsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    NSArray *participants = objects;
                    MessageThread *thread = [[MessageThread alloc]initWithUser:user
                                                                  participants:participants
                                                                      messages:user.messages
                                                                    identifier:[parseThread objectId]
                                                                         title:parseThread[@"title"][0] //for debug purpose because I have set message text to array in fake data
                                                               backgroundImage:[self imageFileToImage:parseThread[@"backgroundImage"]]];
                    [userThreads addObject:thread];
                    count++;
                    bool isDone = NO;
                    if (count == [user.messageThreads count]) {
                        isDone = YES;
                    }
                    completion(userThreads, isDone);
                }];
            }
        } else {
            failure();
        }
    }];
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
                    PFFile *imageFile = parseMessage[@"picture"][0];//bad fake data, parse message is set to an array with PFFile in it
                    UIImage *picture = [self imageFileToImage:imageFile];
                    Message *message = [[Message alloc]initWithText:parseMessage[@"text"]
                                                               user: user
                                                             thread:thread
                                                            picture:picture
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

+ (void)addMessageToThread: (PFObject *)thread
                  withText: (NSString *)text
                   picture: (UIImage *)picture
                completion: (void(^)())completion
{
    PFObject *parseMessage = [PFObject objectWithClassName:@"Message"];
    [parseMessage addObject:text forKey:@"text"];
    NSData *imageData = UIImagePNGRepresentation(picture);
    PFFile *file = [PFFile fileWithName:@"picture" data:imageData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [parseMessage setObject:file forKey:@"picture"];
        [parseMessage addObject:@"NO" forKey:@"isRead"];
        [parseMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFRelation *messageToThread = [parseMessage relationForKey:@"messageThreads"];
            [messageToThread addObject:thread];
            [parseMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                PFRelation *threadToMessage = [thread relationForKey:@"messages"];
                [threadToMessage addObject:parseMessage];
                [thread saveInBackground];
                completion();
            }];
        }];
    }];
}

+ (void)createMessage: (NSString *)text
              picture: (UIImage *) picture
           completion: (void(^)(PFObject *))completion
{
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *userQuery = [PFQuery queryWithClassName:@"UserProxy"];
    [userQuery whereKey:@"identifier" equalTo:currentUser[@"fbId"]];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *proxyUser = objects[0];
        PFObject *message = [PFObject objectWithClassName:@"Message"];
        [message addObject:text forKey:@"text"];
        NSData *imageData = UIImagePNGRepresentation(picture);
        PFFile *file = [PFFile fileWithData:imageData];
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [message setObject:file forKey:@"picture"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                PFRelation *messageToProxyUser = [message relationForKey:@"proxyUsers"];
                [messageToProxyUser addObject:proxyUser];
                [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    completion(message);
                }];
            }];
        }];
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

+ (void)startMessageThreadForUsers: (NSArray *)participants
                       withMessage: (PFObject *) message
                         withTitle: (NSString *)title
                    backroundImage: (UIImage *)backgroundImage
                        completion: (void(^)(PFObject *))completion

{
    PFObject *messageThread = [PFObject objectWithClassName:@"MessageThread"];
    [messageThread setObject:title forKey:@"title"];
    NSData *imageData = UIImagePNGRepresentation(backgroundImage);
    PFFile *file = [PFFile fileWithName:@"backroundImage" data:imageData];
    [file saveInBackground];
    [messageThread setObject:file forKey:@"backgroundImage"];
    [messageThread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFRelation *threadToMessage = [messageThread relationForKey:@"messages"];
        [threadToMessage addObject:message];
        PFRelation *messageToThread = [message relationForKey:@"messageThreads"];
        [messageToThread addObject:messageThread];
        [message saveInBackground];
        for (PFUser *participant in participants) {
            [self storeRelation:participant toMessageThread:messageThread completion:^{
                NSLog(@"created proxy");
            }];
        }
        completion(messageThread);
    }];
}

//uniq check for users to prevent multiplying them, no check for threads, because when the thread is created, it doesn't exist in any user
+ (void)storeRelation: (PFUser *)parseUser
      toMessageThread: (PFObject *)messageThread
           completion: (void(^)())completion

{
    PFRelation *relation = [messageThread relationforKey:@"proxyUsers"];
    [relation addObject:parseUser];
    [messageThread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFQuery *proxyQuery = [PFQuery queryWithClassName:@"UserProxy"];
        [proxyQuery whereKey:@"identifier" equalTo:[parseUser objectForKey:@"fbId"]];
        [proxyQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray *foundProxies = objects;
            PFObject *userProxy;
            if ([foundProxies count] > 0) {
                userProxy = foundProxies[0];
            } else {
                userProxy = [PFObject objectWithClassName:@"UserProxy"];
            }
            [userProxy setObject:[parseUser objectForKey:@"fbId"] forKey:@"identifier"];
            PFRelation *inverseRelation = [userProxy relationForKey:@"threads"];
            [inverseRelation addObject:messageThread];
            [userProxy saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        NSLog(@"proxy saved");
                        completion();
            }];
        }];
    }];
}





@end
