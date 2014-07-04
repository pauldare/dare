//
//  Friend+Methods.h
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "Friend.h"

@interface Friend (Methods)

+ (Friend *)fetchFriendFromParseFriend: (PFUser *)friend inContext: (NSManagedObjectContext *)context;

@end
