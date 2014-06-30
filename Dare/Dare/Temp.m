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
    UIImage *imageOne = [UIImage imageNamed:@"mesOne.jpeg"];
    NSData *imageDataOne = UIImagePNGRepresentation(imageOne);
    PFFile *fileOne = [PFFile fileWithName:@"userPic" data:imageDataOne];
    [fileOne saveInBackground];
    [messageOne addObject:fileOne forKey:@"picture"];
    [messageOne save];
    
    PFObject *messageTwo = [PFObject objectWithClassName:@"Message"];
    [messageTwo addObject:@"message two" forKey:@"text"];
    UIImage *imageTwo = [UIImage imageNamed:@"mesTwo.jpeg"];
    NSData *imageDataTwo = UIImagePNGRepresentation(imageTwo);
    PFFile *fileTwo = [PFFile fileWithName:@"userPic" data:imageDataTwo];
    [fileTwo saveInBackground];
    [messageTwo addObject:fileTwo forKey:@"picture"];
    [messageTwo save];
    
    PFObject *messageThree = [PFObject objectWithClassName:@"Message"];
    [messageThree addObject:@"message three" forKey:@"text"];
    UIImage *imageThree = [UIImage imageNamed:@"mesThree.jpeg"];
    NSData *imageDataThree = UIImagePNGRepresentation(imageThree);
    PFFile *fileThree = [PFFile fileWithName:@"userPic" data:imageDataThree];
    [fileThree saveInBackground];
    [messageThree addObject:fileThree forKey:@"picture"];
    [messageThree save];
    
    PFObject *messageFour = [PFObject objectWithClassName:@"Message"];
    [messageFour addObject:@"message four" forKey:@"text"];
    UIImage *imageFour = [UIImage imageNamed:@"mesFour.jpeg"];
    NSData *imageDataFour = UIImagePNGRepresentation(imageFour);
    PFFile *fileFour = [PFFile fileWithName:@"userPic" data:imageDataFour];
    [fileFour saveInBackground];
    [messageFour addObject:fileThree forKey:@"picture"];
    [messageFour save];
    
    PFRelation *threadOneToMessages = [threadOne relationForKey:@"messages"];
    [threadOneToMessages addObject:messageOne];
    [threadOne setObject:messageOne[@"text"] forKey:@"title"];
    [threadOne setObject:fileOne forKey:@"backgroundImage"];
    [threadOneToMessages addObject:messageTwo];
    [threadOne save];
    
    PFRelation *threadTwoToMessages = [threadTwo relationForKey:@"messages"];
    [threadTwoToMessages addObject:messageThree];
    [threadTwo setObject:messageThree[@"text"] forKey:@"title"];
    [threadTwo setObject:fileThree forKey:@"backgroundImage"];
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
    alice[@"fbId"] = @"1";
    UIImage *aliceImage = [UIImage imageNamed:@"alice.jpg"];
    NSData *imageData = UIImagePNGRepresentation(aliceImage);
    PFFile *file = [PFFile fileWithName:@"userPic" data:imageData];
    [file saveInBackground];
    alice[@"image"] = file;
    
    
    [alice signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            PFUser *bob = [PFUser user];
            bob.username = @"Bob";
            bob.password = @"";
            bob.email = @"email1@example.com";
            bob[@"displayName"] = @"bob";
            bob[@"fbId"] = @"2";
            UIImage *bobImage = [UIImage imageNamed:@"bob.jpg"];
            NSData *imageDataBob = UIImagePNGRepresentation(bobImage);
            PFFile *fileBob = [PFFile fileWithName:@"userPic" data:imageDataBob];
            [fileBob saveInBackground];
            bob[@"image"] = fileBob;
            
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
                                
                                PFRelation *threadOneToAlice = [threadOne relationForKey:@"Users"];
                                [threadOneToAlice addObject:alice];
                                [threadOne save];
                                
                                PFRelation *threadTwoToAlice = [threadTwo relationForKey:@"Users"];
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
                                            
                                            PFRelation *threadTwoToBob = [threadTwo relationForKey:@"Users"];
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

@end
