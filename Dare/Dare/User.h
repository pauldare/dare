//
//  User.h
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (strong, nonatomic) NSString *displayName; //choose, set to fb by default
@property (strong, nonatomic) NSString *userID; //comes from Parse
@property (strong, nonatomic) NSArray *facebookDisplayName; 
@property (strong, nonatomic) NSArray *messageThreads;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) NSArray *messages;

+(User *)getUser;

@end
