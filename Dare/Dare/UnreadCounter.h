//
//  UnreadCounter.h
//  Dare
//
//  Created by Nadia Yudina on 7/19/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnreadCounter : NSObject

@property (nonatomic) NSInteger unreadMessages;

+(UnreadCounter *) sharedCounter;

@end
