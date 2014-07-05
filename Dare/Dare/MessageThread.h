//
//  MessageThread.h
//  Dare
//
//  Created by Nadia on 7/5/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend, Message, User;

@interface MessageThread : NSManagedObject

@property (nonatomic, retain) NSData * backgroundPicture;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * author;
@property (nonatomic, retain) NSSet *friends;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) User *users;
@end

@interface MessageThread (CoreDataGeneratedAccessors)

- (void)addFriendsObject:(Friend *)value;
- (void)removeFriendsObject:(Friend *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
