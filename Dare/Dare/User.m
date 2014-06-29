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
    return [self initWithDisplayName:nil
                      messageThreads:nil
                             friends:nil
                            messages:nil
                          identifier:nil];
}

- (instancetype)initWithDisplayName: (NSString *)displayName
                     messageThreads: (NSArray *)messageThreads
                            friends: (NSArray *)friends
                           messages: (NSMutableArray *)messages
                         identifier: (NSString *)identifier

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
    return [NSString stringWithFormat:@"The user is: %@", self.displayName];
}



@end
