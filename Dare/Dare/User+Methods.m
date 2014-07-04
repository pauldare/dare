//
//  User+Methods.m
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "User+Methods.h"

@implementation User (Methods)

+ (User *)fetchUserFromCurrentUser: (PFUser *)user
                         inContext: (NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    NSString *searchID = user[@"fbId"];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"identifier==%@",searchID];
    fetchRequest.predicate = searchPredicate;
    NSArray *users = [context executeFetchRequest:fetchRequest error:nil];
    if ([users count] == 0) {
        User *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                      inManagedObjectContext:context];
        newUser.identifier = user[@"fbId"];
        newUser.displayName = user[@"displayName"];
        PFFile *imageFile = user[@"image"];
        NSData *imageData = [imageFile getData];
        newUser.profileImage = imageData;
        return newUser;
    } else {
        return users[0];
    }    
}




//- (instancetype)init
//{
//    return [self initWithDisplayName:nil
//                             friends:nil
//                            messages:nil
//                          identifier:nil
//                        profileImage:nil];
//}
//
//- (instancetype)initWithDisplayName: (NSString *)displayName
//                            friends: (NSArray *)friends
//                           messages: (NSMutableArray *)messages
//                         identifier: (NSString *)identifier
//                       profileImage: (UIImage *)profileImage
//
//{
//    self = [super init];
//    if (self) {
//        self.displayName = displayName;
//        self.friends = friends;
//        self.identifier = identifier;
//        self.messages = messages;
//        self.profileImage = profileImage;
//    }
//    return self;
//}
//
//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"The user is: %@", self.displayName];
//}

@end
