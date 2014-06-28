//
//  User.h
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSArray *facebookDisplayName;

+(User *)createUser;

-(NSArray*)getFriendsForUser:(User*) user;

-(NSArray*)getThreadsForUser:(User*) user;

-(NSArray*)getMessagesForUser:(User*)user;

-(void)postUserToParse;

@end
