//
//  User+Methods.h
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "User.h"

@interface User (Methods)

+ (User *)fetchUserFromCurrentUser: (PFUser *)user
                         inContext: (NSManagedObjectContext *)context;

//- (instancetype)initWithDisplayName: (NSString *)displayName
//                            friends: (NSArray *)friends
//                           messages: (NSMutableArray *)messages
//                         identifier: (NSString *)identifier
//                       profileImage: (UIImage *)profileImage;

@end
