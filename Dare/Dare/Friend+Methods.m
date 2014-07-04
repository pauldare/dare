//
//  Friend+Methods.m
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "Friend+Methods.h"

@implementation Friend (Methods)

+ (Friend *)fetchFriendFromParseFriend: (PFUser *)friend
                             inContext: (NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    NSString *searchID = friend[@"fbId"];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"identifier==%@",searchID];
    fetchRequest.predicate = searchPredicate;
    NSArray *friends = [context executeFetchRequest:fetchRequest error:nil];
    if ([friends count] == 0) {
        Friend *newFriend = [NSEntityDescription insertNewObjectForEntityForName:@"Friend"
                                                      inManagedObjectContext:context];
        newFriend.identifier = friend[@"fbId"];
        newFriend.displayName = friend[@"displayName"];
        PFFile *imageFile = friend[@"image"];
        NSData *imageData = [imageFile getData];
        newFriend.image = imageData;
        return newFriend;
    } else {
        return friends[0];
    }
}



@end
