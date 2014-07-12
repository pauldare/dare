 //
//  LogInWithFacebookViewController.m
//  Dare
//
//  Created by Dare on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "LogInWithFacebookViewController.h"
#import "ParseClient.h"
#import "UIColor+DareColors.h"
#import "DareDataStore.h"
#import "DisplayNameSelectViewController.h"
#import "MainScreenViewController.h"

@interface LogInWithFacebookViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginWithFacebook;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) DareDataStore *dataStore;
@end

@implementation LogInWithFacebookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataStore = [DareDataStore sharedDataStore];
    self.overlayView.hidden = YES;
    //[self.view sendSubviewToBack:self.overlayView];
    [_loginWithFacebook addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [_loginWithFacebook setTitleColor:[UIColor DareBlue] forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor DareBlue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.overlayView.backgroundColor = [UIColor DareCellOverlaySolid];
    //[self.view sendSubviewToBack:self.overlayView];
}

-(void)login
{
    [ParseClient loginWithFB:^(BOOL isNEW) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        if (isNEW) {
            self.overlayView.hidden = NO;
            //[self.view bringSubviewToFront:self.overlayView];
            NSLog(@"I am new");
            [ParseClient relateFacebookFriendsInParse:^(bool isDone) {
                if (isDone) {
                    [self.dataStore populateCoreData:^{
                        DisplayNameSelectViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DisplayNameSelectVC"];
                        PFInstallation *installation = [PFInstallation currentInstallation];
                        [installation setObject:[PFUser currentUser] forKey:@"user"];
                        [self presentViewController:viewController animated:YES completion:nil];
                    }];
                }
            } failure:nil];
        } else {
            self.overlayView.hidden = NO;
            NSLog(@"Returning");
            [ParseClient relateFacebookFriendsInParse:^(bool isDone) {
                if (isDone) {
                    [self.dataStore populateCoreData:^{
                        static dispatch_once_t oncePredicate;
                        dispatch_once(&oncePredicate, ^{
                            UINavigationController *mainScreenNavController = [storyboard instantiateViewControllerWithIdentifier:@"MainNavController"];
                            MainScreenViewController *mainScreen = mainScreenNavController.viewControllers[0];
                            mainScreen.fromCancel = NO;
                            mainScreen.fromNew = YES;
                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
                            mainScreen.threads = [[NSMutableArray alloc]initWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
                            [self presentViewController:mainScreenNavController animated:YES completion:nil];
                        });
                    }];
                }
            } failure:nil];
        }
    }];
}


@end
