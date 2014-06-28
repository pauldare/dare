//
//  Message.h
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class MessageThread;
@class User;

@interface Message : NSObject
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) User *poster;
@property (strong, nonatomic) NSString *threadId;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIImage *picture;
@property (nonatomic) BOOL shouldBlur;
@property (nonatomic) NSInteger blurTimer;
@property (nonatomic) BOOL hasBeenViewed;
@property (strong, nonatomic) User *messagePoster;
@property (strong, nonatomic) MessageThread *messageThread;
@property (strong, nonatomic) PFObject *parseObject;

- (instancetype)initWithText: (NSString *)text
                      thread: (NSString *)threadId
                      poster: (User *)poster;



@end
