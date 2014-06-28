//
//  MessageThread.h
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Message.h"

@interface MessageThread : NSObject

@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSArray *participants;

+(MessageThread*)getThread;

-(void)addUserToThread:(User*)user;

-(void)postMessgeToThread:(Message*)message;

-(void)postMessageThreadToParse;

@end
