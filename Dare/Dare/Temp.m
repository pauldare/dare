//
//  Temp.m
//  Dare
//
//  Created by Dare Ryan on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "Temp.h"
#import <Parse/Parse.h>
#import "Constants.h"
//#import <FacebookSDK/FacebookSDK.h>

@implementation Temp


+ (void)fakeData
{
    PFObject *thr1 = [PFObject objectWithClassName:@"MessageThread"];
    [thr1 save];
    PFObject *thr2 = [PFObject objectWithClassName:@"MessageThread"];
    [thr2 save];

    PFObject *mes1 = [PFObject objectWithClassName:@"Message"];
    [mes1 addObject:@"message one" forKey:@"text"];
    [mes1 save];
    PFObject *mes2 = [PFObject objectWithClassName:@"Message"];
    [mes2 addObject:@"message two" forKey:@"text"];
    [mes2 save];
    PFObject *mes3 = [PFObject objectWithClassName:@"Message"];
    [mes3 addObject:@"message three" forKey:@"text"];
    [mes3 save];
    PFObject *mes4 = [PFObject objectWithClassName:@"Message"];
    [mes4 addObject:@"message four" forKey:@"text"];
    [mes4 save];
    PFObject *mes5 = [PFObject objectWithClassName:@"Message"];
    [mes5 addObject:@"message five" forKey:@"text"];
    [mes5 save];
    PFObject *mes6 = [PFObject objectWithClassName:@"Message"];
    [mes6 addObject:@"message six" forKey:@"text"];
    [mes6 save];
    PFObject *mes7 = [PFObject objectWithClassName:@"Message"];
    [mes7 addObject:@"message seven" forKey:@"text"];
    [mes7 save];
    PFObject *mes8 = [PFObject objectWithClassName:@"Message"];
    [mes8 addObject:@"message eight" forKey:@"text"];
    [mes8 save];
    

    PFUser *user = [PFUser user];
    user.username = @"Alice";
    user.password = @"";
    user.email = @"email@example.com";
    user[@"displayName"] = @"alice";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFRelation *rel = [user relationForKey:@"messageThreads"];
            [rel addObject:thr1];
            
            PFUser *user1 = [PFUser user];
            user1.username = @"Bob";
            user1.password = @"";
            user1.email = @"email1@example.com";
            user1[@"displayName"] = @"bob";
            
            [user1 signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    PFRelation *rel1 = [user relationForKey:@"messageThreads"];
                    [rel1 addObject:thr1];
                    
                    PFUser *user2 = [PFUser user];
                    user2.username = @"Cat";
                    user2.password = @"";
                    user2.email = @"email2@example.com";
                    user2[@"displayName"] = @"cat";
                    
                    [user2 signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            PFRelation *rel2 = [user relationForKey:@"messageThreads"];
                            [rel2 addObject:thr2];
                            
                            PFUser *user3 = [PFUser user];
                            user3.username = @"Danny";
                            user3.password = @"";
                            user3.email = @"email3@example.com";
                            user3[@"displayName"] = @"danny";
                            
                            [user3 signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (!error) {
                                    PFRelation *rel3 = [user relationForKey:@"messageThreads"];
                                    [rel3 addObject:thr2];
                                    
                                    //friend relations
                                    PFRelation *frrel = [user relationForKey:@"friends"];
                                    [frrel addObject:user1];
                                    
                                    PFRelation *frrel1 = [user1 relationForKey:@"friends"];
                                    [frrel1 addObject:user];
                                    
                                    PFRelation *frrel2 = [user2 relationForKey:@"friends"];
                                    [frrel2 addObject:user3];
                                    
                                    PFRelation *frrel3 = [user3 relationForKey:@"friends"];
                                    [frrel3 addObject:user2];
                                    
                                    //messages relations
                                    PFRelation *mesrel = [user relationForKey:@"messages"];
                                    [mesrel addObject:mes1];
                                    [mesrel addObject:mes2];
                                    [mesrel addObject:mes3];
                                    
                                    PFRelation *mesrel1 = [user1 relationForKey:@"messages"];
                                    [mesrel1 addObject:mes4];
                                    [mesrel1 addObject:mes5];
                                    
                                    PFRelation *mesrel2 = [user2 relationForKey:@"messages"];
                                    [mesrel2 addObject:mes6];
                                    [mesrel2 addObject:mes7];
                                    
                                    PFRelation *mesrel3 = [user3 relationForKey:@"messages"];
                                    [mesrel3 addObject:mes8];
                                    
                                    //messages to thr
                                    PFRelation *r = [thr1 relationForKey:@"messages"];
                                    [r addObject:mes1];
                                    [r addObject:mes2];
                                    [r addObject:mes3];
                                    [r addObject:mes4];
                                    [r addObject:mes5];
                                    
                                    PFRelation *r1 = [thr2 relationForKey:@"messages"];
                                    [r1 addObject:mes6];
                                    [r1 addObject:mes7];
                                    [r1 addObject:mes8];
                                    
                                    [PFUser logInWithUsernameInBackground:@"Alice" password:@""
                                                                    block:^(PFUser *user, NSError *error) {
                                                                        if (user) {
                                                                            [user save];
                                                            
                                                                            [PFUser logInWithUsernameInBackground:@"Cat" password:@""
                                                                                                            block:^(PFUser *user, NSError *error) {
                                                                                                                if (user) {
                                                                                                                    [user save];
                                                                                                                    NSLog(@"all saved");
                                                                                                                    // Do stuff after successful login.
                                                                                                                } else {
                                                                                                                    // The login failed. Check error to see why.
                                                                                                                }
                                                                                                            }];
                                                                        } else {
                                                                            // The login failed. Check error to see why.
                                                                        }
                                                                    }];
                                    
                                    
                                    
                                    
                                    
                                    // Hooray! Let them use the app now.
                                } else {
                                    NSString *errorString = [error userInfo][@"error"];
                                    // Show the errorString somewhere and let the user try again.
                                }
                            }];

                            
                            // Hooray! Let them use the app now.
                        } else {
                            NSString *errorString = [error userInfo][@"error"];
                            // Show the errorString somewhere and let the user try again.
                        }
                    }];

                } else {
                    NSString *errorString = [error userInfo][@"error"];
                    // Show the errorString somewhere and let the user try again.
                }
            }];
 
            // Hooray! Let them use the app now.
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
        }
    }];
}


//[Parse setApplicationId:ParseAppID
//              clientKey:ParseClientKey];
//
//[PFFacebookUtils initializeFacebook];
//
//NSArray *permissions = @[@"email", @"user_friends"];
//if (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded) {
//    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
//        if (!user) {
//            if (!error) {
//                NSLog(@"Uh oh. The user cancelled the Facebook login.");
//            }
//        } else if (user.isNew) {
//            NSLog(@"User signed up and logged in through Facebook!");
//        } else {
//            NSLog(@"User logged in through Facebook!");
//            NSLog(@"Currently loggen in: %@", [PFUser currentUser]);
//        }
//    }];
//}







//self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//// Override point for customization after application launch.
//self.window.backgroundColor = [UIColor whiteColor];
//[self.window makeKeyAndVisible];
//_faceBookProfileImageContainerView = [[UIView alloc]initWithFrame:self.window.frame];
//[self.window addSubview:_faceBookProfileImageContainerView];
//
//
//-(void)loginSuccess
//{
//    NSString *requestPath = @"me/?fields=name,location,gender,birthday,relationship_status,picture.type(large),email,id";
//    
//    FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:requestPath];
//    
//    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        if (!error) {
//            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
//            
//            NSDictionary *dicFacebookPicture = [userData objectForKey:@"picture"];
//            NSDictionary *dicFacebookData = [dicFacebookPicture objectForKey:@"data"];
//            NSString *sUrlPic= [dicFacebookData objectForKey:@"url"];
//            
//            UIImage* imgProfile = [UIImage imageWithData:
//                                   [NSData dataWithContentsOfURL:
//                                    [NSURL URLWithString: sUrlPic]]];
//            
//            UIImageView *facebookProfileImageView = [[UIImageView alloc] initWithImage:imgProfile];
//            facebookProfileImageView.frame = CGRectMake(_faceBookProfileImageContainerView.frame.origin.x, _faceBookProfileImageContainerView.frame.origin.y, _faceBookProfileImageContainerView.frame.size.width, _faceBookProfileImageContainerView.frame.size.height/2);
//            facebookProfileImageView.backgroundColor = [UIColor redColor];
//            facebookProfileImageView.contentMode = UIViewContentModeScaleToFill;
//            [_faceBookProfileImageContainerView addSubview:facebookProfileImageView];
//            
//            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(facebookProfileImageView.frame.origin.x, facebookProfileImageView.frame.origin.y, facebookProfileImageView.frame.size.width, 60)];
//            nameLabel.text = userData[@"name"];
//            _myUser = [PFUser currentUser];
//            [_myUser setObject:userData[@"name"] forKey:@"faceBookName"];
//            [_myUser setObject:@"Dare" forKey:@"displayName"];
//            
//            
//            nameLabel.textColor = [UIColor redColor];
//            [_faceBookProfileImageContainerView addSubview:nameLabel];
//            [_faceBookProfileImageContainerView bringSubviewToFront:nameLabel];
//            FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/friends"];
//            
//            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                if (!error) {
//                    NSArray *data = [result objectForKey:@"data"];
//                    if (data) {
//                        //we now have an array of NSDictionary entries contating friend data
//                        for (NSMutableDictionary *friendData in data) {
//                            
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                
//                                NSString *friendID = friendData[@"id"];
//                                NSSet *friendSet = [NSSet setWithArray:@[friendID]];
//                                
//                                [_myUser setObject:[friendSet allObjects] forKey:@"friends"];
//                                [_myUser saveInBackground];
//                                
//                                
//                                PFObject *messageThread = [PFObject objectWithClassName:@"MessageThread"];
//                                [messageThread setObject:@[_myUser] forKey:@"participants"];
//                                PFObject *message = [PFObject objectWithClassName:@"Message"];
//                                [_myUser addUniqueObject:messageThread forKey:@"MessageThreads"];
//                                [messageThread addObject:@[message] forKey:@"message"];
//                                
//                                UIImage* friendImgProfile = [UIImage imageWithData:
//                                                             [NSData dataWithContentsOfURL:
//                                                              [NSURL URLWithString:
//                                                               [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", friendID]]]];
//                                
//                                UIImageView *friendFacebookProfileImageView = [[UIImageView alloc] initWithImage:friendImgProfile];
//                                friendFacebookProfileImageView.frame = CGRectMake(_faceBookProfileImageContainerView.frame.origin.x, _faceBookProfileImageContainerView.frame.size.height/2, _faceBookProfileImageContainerView.frame.size.width, _faceBookProfileImageContainerView.frame.size.height/2);
//                                friendFacebookProfileImageView.backgroundColor = [UIColor redColor];
//                                friendFacebookProfileImageView.contentMode = UIViewContentModeScaleToFill;
//                                [_faceBookProfileImageContainerView addSubview:friendFacebookProfileImageView];
//                                
//                                UILabel *friendNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(friendFacebookProfileImageView.frame.origin.x, friendFacebookProfileImageView.frame.origin.y, friendFacebookProfileImageView.frame.size.width, 60)];
//                                friendNameLabel.text = friendData[@"name"];
//                                friendNameLabel.textColor = [UIColor redColor];
//                                [_faceBookProfileImageContainerView addSubview:friendNameLabel];
//                                [_faceBookProfileImageContainerView bringSubviewToFront:friendNameLabel];
//                                
//                                
//                                
//                            });
//                            
//                        }
//                    } else {
//                        NSLog(@"%@", error);
//                    }
//                }
//            }];
//        }
//    }];
//}


@end
