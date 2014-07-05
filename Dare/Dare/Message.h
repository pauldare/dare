//
//  Message.h
//  Dare
//
//  Created by Nadia on 7/5/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MessageThread, User;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSData * author;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) MessageThread *thread;
@property (nonatomic, retain) User *user;

@end
