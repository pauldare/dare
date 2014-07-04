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
                             friends:nil
                            messages:nil
                          identifier:nil
                        profileImage:nil];
}

- (instancetype)initWithDisplayName: (NSString *)displayName
                            friends: (NSArray *)friends
                           messages: (NSMutableArray *)messages
                         identifier: (NSString *)identifier
                        profileImage: (UIImage *)profileImage

{
    self = [super init];
    if (self) {
        self.displayName = displayName;
        self.friends = friends;
        self.messages = messages;
        self.profileImage = profileImage;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"The user is: %@", self.displayName];
}



@end
