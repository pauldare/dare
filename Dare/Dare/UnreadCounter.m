//
//  UnreadCounter.m
//  Dare
//
//  Created by Nadia Yudina on 7/19/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "UnreadCounter.h"

@implementation UnreadCounter


+(UnreadCounter *) sharedCounter
{
    static UnreadCounter *_sharedCounter = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedCounter = [[self alloc] init];
    });
    
    return _sharedCounter;
}

@end
