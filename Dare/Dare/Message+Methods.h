//
//  Message+Methods.h
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "Message.h"

@interface Message (Methods)

+ (Message *)fetchMessageFromParseMessages: (PFObject *)message
                                 inContext: (NSManagedObjectContext *)context;

//- (instancetype)initWithText: (NSString *)text
//                        user: (User *) user
//                      thread: (MessageThread *)thread
//                     picture: (UIImage *)picture
//                      isRead: (BOOL) isRead;

@end
