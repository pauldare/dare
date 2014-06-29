//
//  MessageThread.m
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "MessageThread.h"
#import "User.h"
#import "Message.h"

@implementation MessageThread

- (instancetype)init
{
    return [self initWithUser:nil
                 participants:nil
                     messages:nil
                   identifier:nil];
}

- (instancetype)initWithUser: (User *)user
                participants: (NSArray *)participants
                    messages: (NSMutableArray *)messages
                  identifier: (NSString *)identifier
{
    self = [super init];
    if (self) {
        self.user = user;
        self.participants = participants;
        self.messages = messages;
        self.identifier = identifier;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"The thread has number: %@", self.identifier];
}



//-(void)addUserToThread:(User *)user
//{
//    NSMutableArray *participants = [self.participants mutableCopy];
//    [participants addObject:user];
//    
//    PFQuery *threadQuery = [PFQuery queryWithClassName:@"MessageThread"];
//    [threadQuery includeKey:@"objectId"];
//    [threadQuery whereKey:@"objectId" equalTo:self.ID];
//    
//    [self.parseObject addObject:user.parseObject forKey:@"Users"];
//    [self.parseObject saveInBackground];
//}
//
//-(void)postMessgeToThread:(Message *)message
//{
//    [self.parseObject addObject:message.parseObject forKey:@"Messages"];
//    [self.parseObject saveInBackground];
//}




@end
