//
//  MessageThread+Methods.h
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "MessageThread.h"

@interface MessageThread (Methods)

+ (MessageThread *)fetchThreadFromParseThreads: (PFObject *)thread
                                     inContext: (NSManagedObjectContext *)context;


+ (void)fetchThreadFromParseThreads: (PFObject *)thread
                          inContext: (NSManagedObjectContext *)context
                         completion: (void(^)(MessageThread *))completion;

@end
