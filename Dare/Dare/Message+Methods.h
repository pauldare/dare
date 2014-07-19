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

+ (void)fetchMessageFromParseMessages: (PFObject *)message
                            inContext: (NSManagedObjectContext *)context
                           completion: (void(^)(Message *)) completion;


@end
