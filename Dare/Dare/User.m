//
//  User.m
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "User.h"

@implementation User

+(User *)getUser
{
    PFUser *parseUser = [PFUser currentUser];
    User *user = [[User alloc]init];
    user.displayName = parseUser[@"displayName"];
    user.userID = parseUser.objectId;
    user.messageThreads = parseUser[@"UserThreads"];
    user.friends = parseUser[@"friends"];
    user.messages = parseUser[@"Messages"];
    user.parseObject = parseUser;
    
    return user;
}

@end
