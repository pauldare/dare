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
                   identifier:nil
                        title:nil
              backgroundImage:nil];
}

- (instancetype)initWithUser: (User *)user
                participants: (NSArray *)participants
                    messages: (NSMutableArray *)messages
                  identifier: (NSString *)identifier
                       title: (NSString *)title
             backgroundImage: (UIImage *)image;
{
    self = [super init];
    if (self) {
        self.user = user;
        self.participants = participants;
        self.messages = messages;
        self.identifier = identifier;
        self.title = title;
        self.backgroundImage = image;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"The thread: %@", self.title];
}








@end
