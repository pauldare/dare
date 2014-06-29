//
//  Message.m
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)init
{
    return [self initWithText:nil user:nil thread:nil isRead:NO];
}


- (instancetype)initWithText: (NSString *)text
                        user: (User *) user
                      thread: (MessageThread *)thread
                      isRead: (BOOL) isRead
{
    self = [super init];
    if (self) {
        self.text = text;
        self.user = user;
        self.thread = thread;
        self.isRead = isRead;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"The message is: '%@'", self.text];
}

@end
