//
//  ParseClient.h
//  Dare
//
//  Created by Dare Ryan on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "MessageThread.h"
#import "Message.h"



@interface ParseClient : NSObject

+ (void)loginUser: (NSString *)userName
       completion: (void(^)(NSString *))completion
          failure: (void(^)())failure;

+ (void)getUser: (PFUser *)currentUser
     completion:(void(^)(User *))completion
        failure: (void(^)())failure;

+ (void)loginWithFB: (void(^)())completion;

+ (void)getMessageThreadsForUser: (User *)user
                     completion: (void(^)(NSArray *, bool))completion
                     failure: (void(^)())failure;

+ (void)getMessagesForThread: (MessageThread *)thread
                     user: (User *)user
               completion: (void(^)(NSArray *))completion
                  failure: (void(^)(NSError *))failure;

+ (void)findUserByName: (NSString *)displayName
            completion:(void(^)(User *))completion; //passes User in completion

+ (void)findPFUserByName: (NSString *)displayName
              completion:(void(^)(PFUser *))completion; //returns PFUser

+ (void)addFriend: (PFUser *)friend
        completion:(void(^)())completion; //adds friend on Parse side

+ (void)relateFacebookFriendsInParse: (void(^)(bool))completion
                             failure: (void(^)(NSError *))failure;


@end
