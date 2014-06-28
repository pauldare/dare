//
//  User.m
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)init
{
    return [self initWithDisplayName:@"" messageThreads:@[] friends:@[] messages:@[]];
}

- (instancetype)initWithDisplayName: (NSString *)displayName
                     messageThreads: (NSArray *)messageThreads
                            friends: (NSArray *)friends
                           messages: (NSArray *)messages

{
    self = [super init];
    if (self) {
        self.displayName = displayName;
        self.messageThreads = messageThreads;
        self.friends = friends;
        self.messages = messages;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"The user is: %@, a friend with: %d friends, messages count: %d, threads count: %d", self.displayName, [self.friends count], [self.messages count], [self.messageThreads count]];
}



@end
