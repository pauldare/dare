//
//  MessageThread.h
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "User.h"



@interface MessageThread : NSObject

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSArray *participants;
@property (strong, nonatomic) PFObject *parseObject;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *backgroundImage;

- (instancetype)initWithUser: (User *)user
                participants: (NSArray *)participants
                    messages: (NSMutableArray *)messages
                  identifier: (NSString *)identifier
                       title: (NSString *)title
             backgroundImage: (UIImage *)image;


//-(void)addUserToThread:(User*)user;
//
//-(void)postMessgeToThread:(Message *)message;
//
//-(void)postMessageThreadToParse;

@end
