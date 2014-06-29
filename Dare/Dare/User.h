//
//  User.h
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface User : NSObject
@property (strong, nonatomic) NSString *displayName; //choose, set to fb by default
@property (strong, nonatomic) NSString *identifier; //comes from Parse
@property (strong, nonatomic) NSArray *facebookDisplayName; 
@property (strong, nonatomic) NSArray *messageThreads;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) PFUser *parseObject;

- (instancetype)initWithDisplayName: (NSString *)displayName
                     messageThreads: (NSArray *)messageThreads
                            friends: (NSArray *)friends
                           messages: (NSMutableArray *)messages
                         identifier: (NSString *)identifier;

@end
