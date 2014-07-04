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
        NSData *imageData = [imageFile getData];
        newThread.backgroundPicture = imageData;
        return newThread;
    } else {
        return threads[0];
    }
}


//- (instancetype)init
//{
//    return [self initWithUser:nil
//                 participants:nil
//                     messages:nil
//                   identifier:nil
//                        title:nil
//              backgroundImage:nil];
//}
//
//- (instancetype)initWithUser: (User *)user
//                participants: (NSArray *)participants
//                    messages: (NSMutableArray *)messages
//                  identifier: (NSString *)identifier
//                       title: (NSString *)title
//             backgroundImage: (UIImage *)image;
//{
//    self = [super init];
//    if (self) {
//        self.user = user;
//        self.participants = participants;
//        self.messages = messages;
//        self.identifier = identifier;
//        self.title = title;
//        self.backgroundImage = image;
//    }
//    return self;
//}
//
//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"The thread: %@", self.title];
//}

@end
