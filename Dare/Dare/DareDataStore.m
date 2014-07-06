//
//  DareDataStore.m
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "DareDataStore.h"
#import "User+Methods.h"
#import "Friend+Methods.h"
#import "Message+Methods.h"
#import "MessageThread+Methods.h"
#import "ParseClient.h"

@implementation DareDataStore

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+(DareDataStore *) sharedDataStore
{
    static DareDataStore *_sharedDataStore = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedDataStore = [[self alloc] init];
    });
    
    return _sharedDataStore;
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void) cleanCoreData
{
    [self.managedObjectContext lock];
    NSArray *stores = [self.persistentStoreCoordinator persistentStores];
    for (NSPersistentStore *store in stores) {
        [self.persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    [self.managedObjectContext unlock];    
    _managedObjectContext = nil;
    _persistentStoreCoordinator = nil;
    _managedObjectModel = nil;
}


- (void)populateCoreData: (void(^)())completion
{
    if ([PFUser currentUser]) {
        [ParseClient queryForFriends:^(NSArray *friends) {
            User *loggedUser = [User fetchUserFromCurrentUser:[PFUser currentUser]
                                 inContext:self.managedObjectContext];
            if ([friends count] != 0) {
                for (PFUser *friend in friends) {
                    Friend *newFriend = [Friend fetchFriendFromParseFriend:friend inContext:self.managedObjectContext];
                    [loggedUser addFriendsObject:newFriend];
                }
            } else {
                completion();
            }
            [ParseClient getMessageThreadsForUser:loggedUser completion:^(NSArray *threads) {
                if ([threads count] != 0) {
                    for (PFObject *thread in threads) {
                        MessageThread *newThread = [MessageThread fetchThreadFromParseThreads:thread inContext:self.managedObjectContext];
                        [loggedUser addThreadsObject:newThread];
                        [ParseClient getFriendsForThread:thread completion:^(NSArray *threadFriends) {
                            for (PFUser *threadFriend in threadFriends) {
                                Friend *friendFromThread = [Friend fetchFriendFromParseFriend:threadFriend inContext:self.managedObjectContext];
                                [newThread addFriendsObject:friendFromThread];
                            }
                            [ParseClient getMessagesForThread:newThread user:loggedUser completion:^(NSArray *messages) {
                                for (PFObject *message in messages) {
                                    Message *newMessage = [Message fetchMessageFromParseMessages:message inContext:self.managedObjectContext];
                                    [newThread addMessagesObject:newMessage];
                                    newMessage.user = loggedUser;
                                }
                                [self saveContext];
                                completion();
                            } failure:nil];
                        }];
                    }
                } else {
                    completion();
                }
            } failure:nil];
        }];
    } else {
        NSLog(@"no one is logged");
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Dare" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Dare.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
