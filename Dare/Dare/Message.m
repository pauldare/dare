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
    return [self initWithText:nil thread:nil poster:nil];
}

- (instancetype)initWithText: (NSString *)text
                      thread: (NSString *)threadId
                      poster: (User *)poster
{
    self = [super init];
    if (self) {
        self.text = text;
        self.poster = poster;
        self.threadId = threadId;
    }
    return self;
}
@end
