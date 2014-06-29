//
//  Message.h
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "MessageThread.h"


@interface Message : NSObject
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) MessageThread *thread;
@property (strong, nonatomic) NSString *threadId;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIImage *picture;
@property (nonatomic) BOOL shouldBlur;
@property (nonatomic) NSInteger blurTimer;
@property (nonatomic) BOOL isRead;
@property (strong, nonatomic) User *messagePoster;
@property (strong, nonatomic) MessageThread *messageThread;
@property (strong, nonatomic) PFObject *parseObject;


- (instancetype)initWithText: (NSString *)text
                        user: (User *) user
                      thread: (MessageThread *)thread
                      isRead: (BOOL) isRead;


@end
