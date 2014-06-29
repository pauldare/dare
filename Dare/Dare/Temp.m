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
    PFObject *threadOne = [PFObject objectWithClassName:@"MessageThread"];
    [threadOne save];
    PFObject *threadTwo = [PFObject objectWithClassName:@"MessageThread"];
    [threadTwo save];

    PFObject *messageOne = [PFObject objectWithClassName:@"Message"];
    [messageOne addObject:@"message one" forKey:@"text"];
    [messageOne save];
    PFObject *messageTwo = [PFObject objectWithClassName:@"Message"];
    [messageTwo addObject:@"message two" forKey:@"text"];
    [messageTwo save];
    PFObject *messageThree = [PFObject objectWithClassName:@"Message"];
    [messageThree addObject:@"message three" forKey:@"text"];
    [messageThree save];
    PFObject *messageFour = [PFObject objectWithClassName:@"Message"];
    [messageFour addObject:@"message four" forKey:@"text"];
    [messageFour save];
    
    PFRelation *threadOneToMessages = [threadOne relationForKey:@"messages"];
    [threadOneToMessages addObject:messageOne];
    [threadOneToMessages addObject:messageTwo];
    [threadOne save];
    
    PFRelation *threadTwoToMessages = [threadTwo relationForKey:@"messages"];
    [threadTwoToMessages addObject:messageThree];
    [threadTwoToMessages addObject:messageFour];
    [threadTwo save];
    
    PFRelation *messageOneToThreadOne = [messageOne relationForKey:@"messageThreads"];
    [messageOneToThreadOne addObject:threadOne];
    [messageOne save];
    
    PFRelation *messageTwoToThreadOne = [messageTwo relationForKey:@"messageThreads"];
    [messageTwoToThreadOne addObject:threadOne];
    [messageTwo save];
    
    PFRelation *messageThreeToThreadTwo = [messageThree relationForKey:@"messageThreads"];
    [messageThreeToThreadTwo addObject:threadTwo];
    [messageThree save];
    
    PFRelation *messageFourToThreadTwo = [messageFour relationForKey:@"messageThreads"];
    [messageFourToThreadTwo addObject:threadTwo];
    [messageFour save];

    PFUser *alice = [PFUser user];
    alice.username = @"Alice";
    alice.password = @"";
    alice.email = @"email@example.com";
    alice[@"displayName"] = @"alice";
    
    [alice signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            PFUser *bob = [PFUser user];
            bob.username = @"Bob";
            bob.password = @"";
            bob.email = @"email1@example.com";
            bob[@"displayName"] = @"bob";
            
            [bob signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {

                    [PFUser logInWithUsernameInBackground:@"Alice" password:@"" block:^(PFUser *user, NSError *error) {
                            if (user) {
                                
                                PFUser *alice = [PFUser currentUser];
                                
                                PFRelation *aliceFriendRelation = [alice relationForKey:@"friends"];
                                [aliceFriendRelation addObject:bob];
                                
                                PFRelation *aliceThreads = [alice relationForKey:@"messageThreads"];
                                [aliceThreads addObject:threadOne];
                                [aliceThreads addObject:threadTwo];
                                
                                PFRelation *threadOneToAlice = [threadOne relationForKey:@"User"];
                                [threadOneToAlice addObject:alice];
                                [threadOne save];
                                
                                PFRelation *threadTwoToAlice = [threadTwo relationForKey:@"User"];
                                [threadTwoToAlice addObject:alice];
                                [threadTwo save];
                                
                                PFRelation *aliceToMessages = [alice relationForKey:@"messages"];
                                [aliceToMessages addObject:messageOne];
                                [aliceToMessages addObject:messageTwo];
                                [aliceToMessages addObject:messageThree];
                                
                                PFRelation *messageOneToAlice = [messageOne relationForKey:@"User"];
                                [messageOneToAlice addObject:alice];
                                [messageOne save];
                                
                                PFRelation *messageTwoToAlice = [messageTwo relationForKey:@"User"];
                                [messageTwoToAlice addObject:alice];
                                [messageTwo save];
                                
                                PFRelation *messageThreeToAlice = [messageThree relationForKey:@"User"];
                                [messageThreeToAlice addObject:alice];
                                [messageThree save];
                                
                                [user save];
                                [PFUser logOut];
                                
                                                                    
                                [PFUser logInWithUsernameInBackground:@"Bob" password:@"" block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            
                                            PFUser *bob = [PFUser currentUser];
                                            
                                            PFRelation *bobFriendRelation = [bob relationForKey:@"friends"];
                                            [bobFriendRelation addObject:alice];
                                            
                                            PFRelation *bobThreads = [bob relationForKey:@"messageThreads"];
                                            [bobThreads addObject:threadTwo];
                                            
                                            PFRelation *threadTwoToBob = [threadTwo relationForKey:@"User"];
                                            [threadTwoToBob addObject:bob];
                                            [threadTwo save];
                                            
                                            PFRelation *bobToMessages = [bob relationForKey:@"messages"];
                                            [bobToMessages addObject:messageFour];
                                            
                                            PFRelation *messageFourToBob = [messageFour relationForKey:@"User"];
                                            [messageFourToBob addObject:bob];
                                            [messageFour save];

                                            [user save];
                                            [PFUser logOut];
                                            
                                            NSLog(@"done");
                                            // Do stuff after successful login.
                                        } else {
                                            // The login failed. Check error to see why.
                                        }
                                    }];
                                
                            } else {
                                // The login failed. Check error to see why.
                            }
                        }];

                } else {
                    //NSString *errorString = [error userInfo][@"error"];
                    // Show the errorString somewhere and let the user try again.
                }
            }];
        } else {
            //NSString *errorString = [error userInfo][@"error"];
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
