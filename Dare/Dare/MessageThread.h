//
//  MessageThread.h
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class User;
@class Message;

@interface MessageThread : NSObject

@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSArray *participants;
@property (strong, nonatomic) PFObject *parseObject;

+(MessageThread*)getThread;

-(void)addUserToThread:(User*)user;

-(void)postMessgeToThread:(Message *)message;

-(void)postMessageThreadToParse;

@end
