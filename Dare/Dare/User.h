//
//  User.h
//  Dare
//
//  Created by Nadia on 7/5/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend, Message, MessageThread;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSData * profileImage;
@property (nonatomic, retain) NSSet *friends;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *threads;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFriendsObject:(Friend *)value;
- (void)removeFriendsObject:(Friend *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addThreadsObject:(MessageThread *)value;
- (void)removeThreadsObject:(MessageThread *)value;
- (void)addThreads:(NSSet *)values;
- (void)removeThreads:(NSSet *)values;

@end
