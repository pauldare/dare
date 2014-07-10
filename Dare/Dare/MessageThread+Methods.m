//
//  MessageThread+Methods.m
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "MessageThread+Methods.h"

@implementation MessageThread (Methods)

+ (MessageThread *)fetchThreadFromParseThreads: (PFObject *)thread
                         inContext: (NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
    NSString *searchID = thread.objectId;
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"identifier==%@",searchID];
    fetchRequest.predicate = searchPredicate;
    NSArray *threads = [context executeFetchRequest:fetchRequest error:nil];
    if ([threads count] == 0) {
        MessageThread *newThread = [NSEntityDescription insertNewObjectForEntityForName:@"MessageThread"
                                                      inManagedObjectContext:context];
        newThread.identifier = thread.objectId;
        newThread.title = thread[@"title"];
        PFFile *imageFile = thread[@"backgroundImage"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            newThread.backgroundPicture = data;
        }];
        PFFile *authorImage = thread[@"author"];
        [authorImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            newThread.author = data;
        }];
        newThread.createdAt = thread.createdAt;
        return newThread;
    } else {
        return threads[0];
    }
}


@end
