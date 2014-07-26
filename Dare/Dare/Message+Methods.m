//
//  Message+Methods.m
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "Message+Methods.h"
#import "ParseClient.h"

@implementation Message (Methods)


+ (Message *)fetchMessageFromParseMessages: (PFObject *)message
                                     inContext: (NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    NSString *searchID = message.objectId;
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"identifier==%@",searchID];
    fetchRequest.predicate = searchPredicate;
    NSArray *messages = [context executeFetchRequest:fetchRequest error:nil];
    if ([messages count] == 0) {
        Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
                                                                 inManagedObjectContext:context];
        newMessage.identifier = message.objectId;
        newMessage.text = message[@"text"];
        PFFile *imageFile = message[@"picture"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            newMessage.picture = data;
        }];
        PFFile *authorImage = message[@"author"];
        [authorImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            newMessage.author = data;
        }];
        newMessage.createdAt = message.createdAt;
        newMessage.blurTimer = message[@"blurTimer"];
        
        PFRelation *viewersRelation = [message relationForKey:@"viewers"];
        PFQuery *viewersQuery = [viewersRelation query];
        [viewersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects containsObject:[PFUser currentUser]]) {
                newMessage.isViewed = @1;
            } else {
                newMessage.isViewed = @0;
            }
        }];
        newMessage.isRead = @0;
      
        return newMessage;
    } else {
        return messages[0];
    }
}


+ (void)fetchMessageFromParseMessages: (PFObject *)message
                                 inContext: (NSManagedObjectContext *)context
                                completion: (void(^)(Message *)) completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    NSString *searchID = message.objectId;
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"identifier==%@",searchID];
    fetchRequest.predicate = searchPredicate;
    NSArray *messages = [context executeFetchRequest:fetchRequest error:nil];
    if ([messages count] == 0) {
        Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
                                                            inManagedObjectContext:context];
        newMessage.identifier = message.objectId;
        newMessage.text = message[@"text"];
        PFFile *imageFile = message[@"picture"];
        newMessage.createdAt = message.createdAt;
        newMessage.blurTimer = message[@"blurTimer"];
        newMessage.isRead = @0;
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            newMessage.picture = data;
            PFFile *authorImage = message[@"author"];
            [authorImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                newMessage.author = data;
                PFRelation *viewersRelation = [message relationForKey:@"viewers"];
                PFQuery *viewersQuery = [viewersRelation query];
                [viewersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if ([objects containsObject:[PFUser currentUser]]) {
                        newMessage.isViewed = @1;
                    } else {
                        newMessage.isViewed = @0;
                    }
                    completion(newMessage);
                }];
            }];
        }];
    } else {
        completion(messages[0]);
    }

}




@end
