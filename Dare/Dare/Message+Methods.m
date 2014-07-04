//
//  Message+Methods.m
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "Message+Methods.h"

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
        NSData *imageData = [imageFile getData];
        newMessage.picture = imageData;
        return newMessage;
    } else {
        return messages[0];
    }
}


//- (instancetype)init
//{
//    return [self initWithText:nil user:nil thread:nil picture: nil isRead:NO];
//}
//
//
//- (instancetype)initWithText: (NSString *)text
//                        user: (User *) user
//                      thread: (MessageThread *)thread
//                     picture: (UIImage *)picture
//                      isRead: (BOOL) isRead
//{
//    self = [super init];
//    if (self) {
//        self.text = text;
//        self.user = user;
//        self.thread = thread;
//        self.picture = picture;
//        self.isRead = isRead;
//    }
//    return self;
//}
//
//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"The message is: '%@'", self.text];
//}


@end
