//
//  MessageThread.m
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "MessageThread.h"
#import <Parse/Parse.h>

@implementation MessageThread

+(MessageThread *)getThread
{
    return nil;
}

-(void)addUserToThread:(User *)user
{
    
    NSMutableArray *participants = [self.participants mutableCopy];
    [participants addObject:user];
    
    PFQuery *threadQuery = [PFQuery queryWithClassName:@"MessageThread"];
#warning Include ID For Thread
    [threadQuery includeKey:@"objectId"];
    [threadQuery whereKey:@"objectId" equalTo:self.ID];
    [threadQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            
            PFObject *thread = objects[0];
            
            PFQuery *userQuery = [PFQuery queryWithClassName:@"User"];
            [userQuery includeKey:@"objectId"];
            [userQuery whereKey:@"objectId" equalTo: user.userID];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (objects.count > 0) {
                    PFUser *user = objects[0];
#warning Add @"users key"
                    [thread addObject:user forKey:@""];
                    [thread saveInBackground];
                }
            }];
        }
    }];
}


@end
