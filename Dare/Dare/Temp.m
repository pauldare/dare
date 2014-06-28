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
    PFUser *user = [PFUser user];
    user.username = @"Alice";
    user.password = @"";
    user.email = @"email@example.com";
    
    
    PFUser *user1 = [PFUser user];
    user.username = @"Bob";
    user.password = @"";
    user.email = @"email1@example.com";
    
    PFUser *user2 = [PFUser user];
    user.username = @"Cat";
    user.password = @"";
    user.email = @"email2@example.com";
    
    PFUser *user3 = [PFUser user];
    user.username = @"Danny";
    user.password = @"";
    user.email = @"email3@example.com";
    
    PFObject *thr1 = [PFObject objectWithClassName:@"MessageThread"];
    
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
