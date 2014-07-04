//
//  Message.h
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MessageThread, User;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) MessageThread *thread;

@end
