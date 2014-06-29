//
//  ParseClient.h
//  Dare
//
//  Created by Dare Ryan on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ParseClient : NSObject

+ (void)loginUser: (NSString *)userName
       completion: (void(^)(NSString *))completion
          failure: (void(^)())failure;

+ (void)getLoggedInUser: (void(^)(User *))completion
            WithFailure: (void(^)())failure;

+ (void)loginWithFB;


@end
