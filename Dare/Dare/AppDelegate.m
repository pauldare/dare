//
//  AppDelegate.m
//  Dare
//
//  Created by Dare Ryan on 6/25/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate()
@property (strong, nonatomic) UIView *faceBookProfileImageContainerView;
@property (strong, nonatomic) PFUser *myUser;
@end


@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:ParseAppID
                  clientKey:ParseClientKey];
    
    [PFFacebookUtils initializeFacebook];
    
    NSArray *permissions = @[@"email", @"user_friends"];
    if (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded) {
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
            if (!user) {
                if (!error) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                }
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
            } else {
                NSLog(@"User logged in through Facebook!");
                [self loginSuccess];
                
                NSLog(@"Currently loggen in: %@", [PFUser currentUser]);
            }
        }];
    }else{
        
        //[self loginSuccess];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    _faceBookProfileImageContainerView = [[UIView alloc]initWithFrame:self.window.frame];
    [self.window addSubview:_faceBookProfileImageContainerView];
    
    
    return YES;
}

-(void)loginSuccess
{
    NSString *requestPath = @"me/?fields=name,location,gender,birthday,relationship_status,picture.type(large),email,id";
    
    FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:requestPath];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
            
            NSDictionary *dicFacebookPicture = [userData objectForKey:@"picture"];
            NSDictionary *dicFacebookData = [dicFacebookPicture objectForKey:@"data"];
            NSString *sUrlPic= [dicFacebookData objectForKey:@"url"];
            
            UIImage* imgProfile = [UIImage imageWithData:
                                   [NSData dataWithContentsOfURL:
                                    [NSURL URLWithString: sUrlPic]]];
            
            UIImageView *facebookProfileImageView = [[UIImageView alloc] initWithImage:imgProfile];
            facebookProfileImageView.frame = CGRectMake(_faceBookProfileImageContainerView.frame.origin.x, _faceBookProfileImageContainerView.frame.origin.y, _faceBookProfileImageContainerView.frame.size.width, _faceBookProfileImageContainerView.frame.size.height/2);
            facebookProfileImageView.backgroundColor = [UIColor redColor];
            facebookProfileImageView.contentMode = UIViewContentModeScaleToFill;
            [_faceBookProfileImageContainerView addSubview:facebookProfileImageView];
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(facebookProfileImageView.frame.origin.x, facebookProfileImageView.frame.origin.y, facebookProfileImageView.frame.size.width, 60)];
            nameLabel.text = userData[@"name"];
            _myUser = [PFUser currentUser];
            [_myUser setObject:userData[@"name"] forKey:@"faceBookName"];
            [_myUser setObject:@"Dare" forKey:@"displayName"];
            
            
            nameLabel.textColor = [UIColor redColor];
            [_faceBookProfileImageContainerView addSubview:nameLabel];
            [_faceBookProfileImageContainerView bringSubviewToFront:nameLabel];
            FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/friends"];
            
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSArray *data = [result objectForKey:@"data"];
                    if (data) {
                        //we now have an array of NSDictionary entries contating friend data
                        for (NSMutableDictionary *friendData in data) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                NSString *friendID = friendData[@"id"];
                                NSSet *friendSet = [NSSet setWithArray:@[friendID]];
                                
                                [_myUser setObject:[friendSet allObjects] forKey:@"friends"];
                                [_myUser saveInBackground];
                                
                                
                                PFObject *messageThread = [PFObject objectWithClassName:@"MessageThread"];
                                [messageThread setObject:@[_myUser] forKey:@"participants"];
                                PFObject *message = [PFObject objectWithClassName:@"Message"];
                                [_myUser addUniqueObject:messageThread forKey:@"MessageThreads"];
                                [messageThread addObject:@[message] forKey:@"message"];
                                
                                UIImage* friendImgProfile = [UIImage imageWithData:
                                                             [NSData dataWithContentsOfURL:
                                                              [NSURL URLWithString:
                                                               [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", friendID]]]];
                                
                                UIImageView *friendFacebookProfileImageView = [[UIImageView alloc] initWithImage:friendImgProfile];
                                friendFacebookProfileImageView.frame = CGRectMake(_faceBookProfileImageContainerView.frame.origin.x, _faceBookProfileImageContainerView.frame.size.height/2, _faceBookProfileImageContainerView.frame.size.width, _faceBookProfileImageContainerView.frame.size.height/2);
                                friendFacebookProfileImageView.backgroundColor = [UIColor redColor];
                                friendFacebookProfileImageView.contentMode = UIViewContentModeScaleToFill;
                                [_faceBookProfileImageContainerView addSubview:friendFacebookProfileImageView];
                                
                                UILabel *friendNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(friendFacebookProfileImageView.frame.origin.x, friendFacebookProfileImageView.frame.origin.y, friendFacebookProfileImageView.frame.size.width, 60)];
                                friendNameLabel.text = friendData[@"name"];
                                friendNameLabel.textColor = [UIColor redColor];
                                [_faceBookProfileImageContainerView addSubview:friendNameLabel];
                                [_faceBookProfileImageContainerView bringSubviewToFront:friendNameLabel];
                                
                                
                                
                            });
                            
                        }
                    } else {
                        NSLog(@"%@", error);
                    }
                }
            }];
        }
    }];
    
    
    
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
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
