//
//  AppDelegate.m
//  Dare
//
//  Created by Dare Ryan on 6/25/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "Temp.h"
#import "ParseClient.h"
#import "Message.h"
#import "MessageThread.h"
#import "DareDataStore.h"
#import "Friend+Methods.h"
#import "DareDataStore.h"
#import "MainScreenViewController.h"



@interface AppDelegate()
//@property (strong, nonatomic) UIView *faceBookProfileImageContainerView;
//@property (strong, nonatomic) PFUser *myUser;

@property (strong, nonatomic) DareDataStore *dataStore;
@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:ParseAppID
                  clientKey:ParseClientKey];
    self.dataStore = [DareDataStore sharedDataStore];
    
    //[[DareDataStore sharedDataStore]cleanCoreData:^{
        [PFFacebookUtils initializeFacebook];
        if (FBSession.activeSession.state == FBSessionStateOpen ||
            FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            [self.dataStore populateCoreData:^{
                NSLog(@"CUrrenly logged: %@", [PFUser currentUser][@"displayName"]);
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
                NSArray *threadsCD = [[NSMutableArray alloc]initWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
                NSMutableArray *threads = [[NSMutableArray alloc]initWithArray:threadsCD];
                NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
                [threads sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
                //sleep(2);
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"MainNavController"];
                MainScreenViewController *main = navigationController.viewControllers[0];
                navigationController.navigationBarHidden = YES;
                main.threads = [[NSMutableArray alloc]initWithArray:threads];
                self.window.rootViewController = navigationController;
            }];
        } else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"InitialNavController"];
            navigationController.navigationBarHidden = YES;
            self.window.rootViewController = navigationController;
        }
    //}];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.dataStore saveContext];
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
#warning uncomment code to terminate FB session
    //    FBSession *activeSession = [FBSession activeSession];
    //    [activeSession closeAndClearTokenInformation];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
    
    FBSession *activeSession = [FBSession activeSession];
    
//    if (activeSession.state != FBSessionStateCreatedTokenLoaded) {
//        
//        NSLog(@"from open url");
//    } else {
//        NSLog(@"no token");
//    }
    
//    if (activeSession.isOpen) {
//        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
//        
//        
//    }
    
}



@end
