//
//  ParseClient.m
//  Dare
//
//  Created by Dare Ryan on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "ParseClient.h"


@implementation ParseClient

+ (void)queryForFriends: (void(^)(NSArray *))completion
{
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *friendsRelation = [currentUser relationForKey:@"friends"];
    PFQuery *friendsQuery = [friendsRelation query];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray *friends = objects;
        completion(friends);
    }];
}


+ (void)imageFileToImage: (PFFile *)imageFile completion: (void(^)(UIImage *))completion
{
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        completion(image);
    }];
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
                        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [self fetchUserProfilePicture:^(NSData *imageData) { //if fails should handle offer to take a picture from camera of device library
                                PFFile *file = [PFFile fileWithName:@"userPic" data:imageData];
                                [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    [currentUser setObject:file forKey:@"image"];
                                    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                        isNEW = YES;
                                        completion(isNEW);
                                    }];
                                }];
                            }];
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

+ (void)getFriendsForThread: (PFObject *) thread
                 completion: (void(^)(NSArray *))completion
{
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *friendsRelation = [thread relationForKey:@"proxyUsers"];
    PFQuery *query = [friendsRelation query];
    [query whereKey:@"identifier" notEqualTo:currentUser[@"fbId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completion(objects);
    }];
}

+ (void)getMessageThreadsForUser: (User *)user
                     completion: (void(^)(NSArray *))completion
                     failure: (void(^)())failure
{
    PFQuery *userQuery = [PFQuery queryWithClassName:@"UserProxy"];
    [userQuery whereKey:@"identifier" equalTo:user.identifier];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] != 0) {
            PFObject *userProxy = objects[0];
            PFRelation *proxyToThreads = [userProxy relationForKey:@"threads"];
            PFQuery *proxyToThreadsQuery = [proxyToThreads query];
            [proxyToThreadsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSArray *threads = objects;
                completion(threads);
            }];
        } else {
            completion(nil);
            NSLog(@"no proxy found");
        }
    }];
}

+ (void)getMessagesForThread: (MessageThread *)thread
                        user: (User *)user
                completion: (void(^)(NSArray *))completion
                   failure: (void(^)(NSError *))failure
{
    PFQuery *threadQueryOnId = [PFQuery queryWithClassName:@"MessageThread"];
    [threadQueryOnId whereKey:@"objectId" equalTo:thread.identifier];
    [threadQueryOnId findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFObject *parseThread = objects[0];
            PFRelation *threadRelation = [parseThread relationForKey:@"messages"];
            PFQuery *threadQuery = [threadRelation query];
            [threadQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSArray *parseMessages = objects;
                completion(parseMessages);
            }];
        } else {
            failure(error);
        }
    }];
}

+ (void)addMessageToThread: (MessageThread *)thread
                  withText: (NSString *)text
                   picture: (UIImage *)picture
                 blurTimer: (NSInteger)blurTimer
                completion: (void(^)(PFObject *))completion
{
    PFQuery *threadQueryOnId = [PFQuery queryWithClassName:@"MessageThread"];
    [threadQueryOnId whereKey:@"objectId" equalTo:thread.identifier];
    [threadQueryOnId findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *thread = objects[0];
        [self createMessage:text picture:picture completion:^(PFObject *message) {
            [message setObject:@(blurTimer) forKey:@"blurTimer"];
            //[message setObject:@"NO" forKey:@"isViewed"];
            PFRelation *messageToThread = [message relationForKey:@"messageThreads"];
            [messageToThread addObject:thread];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                PFRelation *threadToMessage = [thread relationForKey:@"messages"];
                [threadToMessage addObject:message];
                [thread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        completion(message);
                    } else {
                        NSLog(@"%@", error);
                    }
                }];
            }];
        }];
    }];
}

+ (void)createMessage: (NSString *)text
              picture: (UIImage *) picture
           completion: (void(^)(PFObject *))completion
{
    PFUser *currentUser = [PFUser currentUser];
//    PFQuery *userQuery = [PFQuery queryWithClassName:@"UserProxy"];
//    [userQuery whereKey:@"identifier" equalTo:currentUser[@"fbId"]];
//    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        PFObject *proxyUser = objects[0];
        PFObject *message = [PFObject objectWithClassName:@"Message"];
        [message setObject:text forKey:@"text"];
        //[message setObject:@"NO" forKey:@"isRead"];
        NSData *imageData =  UIImageJPEGRepresentation(picture, 0.05f);
        PFFile *file = [PFFile fileWithData:imageData];
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [message setObject:file forKey:@"picture"];
            PFFile *author = currentUser[@"image"];
            [message setObject:author forKey:@"author"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                PFRelation *messageToProxyUser = [message relationForKey:@"proxyUsers"];
//                [messageToProxyUser addObject:proxyUser];
//                [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    completion(message);
//                }];
            }];
        }];
//    }];
}


+ (void)findUserByName: (NSString *)displayName
            completion:(void(^)(User *))completion
{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"displayName" equalTo:displayName];
    NSArray *foundUsers = [userQuery findObjects];
    if ([foundUsers count] > 0) {
        PFUser *foundUser = foundUsers[0];
        //to finish when time comes
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
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFUser *foundUser = objects[0];
            completion(foundUser);
        } else {
            completion(nil);
        }
    }];
}


+ (void)relateFriend: (PFUser *)friend
       completion:(void(^)())completion//adds PFUser to friends relation
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        PFRelation *friendRelation = [currentUser relationForKey:@"friends"];
        [friendRelation addObject:friend];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            completion();
        }];
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
                            BOOL isDone = NO;
                            if (count == [data count]) {
                                isDone = YES;
                            }
                            completion(isDone);
                        }];
                    }];
                }
            }
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
    PFUser *currentUser = [PFUser currentUser];
    PFObject *messageThread = [PFObject objectWithClassName:@"MessageThread"];
    [messageThread setObject:title forKey:@"title"];
    [messageThread setObject:currentUser[@"image"] forKey:@"author"];
    NSData *imageData =  UIImageJPEGRepresentation(backgroundImage, 0.05f);
    PFFile *file = [PFFile fileWithName:@"backroundImage" data:imageData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [messageThread setObject:file forKey:@"backgroundImage"];
        [messageThread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFRelation *threadToMessage = [messageThread relationForKey:@"messages"];
            [threadToMessage addObject:message];
            PFRelation *messageToThread = [message relationForKey:@"messageThreads"];
            [messageToThread addObject:messageThread];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self storeRelation:[PFUser currentUser] toMessageThread:messageThread completion:^{
                for (PFUser *participant in participants) {
                    [self storeRelation:participant toMessageThread:messageThread completion:^{
                        NSLog(@"created proxy");
                    }];
                }
                completion(messageThread);
            }];
        }];
        }];
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


+ (void)storeRelation: (PFUser *)parseUser toViewersListOfMessage: (PFObject *)message
           completion: (void(^)())completion
{
    PFRelation *relation = [message relationforKey:@"viewers"];
    [relation addObject:parseUser];
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completion();
    }];
}

+ (void)storeRelation: (PFUser *)parseUser toReadersListForMessage: (PFObject *)message
           completion: (void(^)())completion
{
    PFRelation *relation = [message relationforKey:@"readers"];
    [relation addObject:parseUser];
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completion();
    }];
}

+ (void)fetchMessage: (Message *)message completion: (void(^)(PFObject *))completion
{
    PFQuery *messageQueryOnId = [PFQuery queryWithClassName:@"Message"];
    [messageQueryOnId whereKey:@"objectId" equalTo:message.identifier];
    [messageQueryOnId findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *parseMessage = objects[0];
        completion(parseMessage);
    }];
}





@end
