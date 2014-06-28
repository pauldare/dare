//
//  MessageThread.m
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "MessageThread.h"

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
    
    [self.parseObject addObject:user.parseObject forKey:@""];
    [self.parseObject saveInBackground];
}

-(void)postMessgeToThread:(Message *)message
{
#warning add relation key
    [self.parseObject addObject:message.parseObject forKey:@""];
    [self.parseObject saveInBackground];
}




@end
