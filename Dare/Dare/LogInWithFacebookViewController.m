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

@interface LogInWithFacebookViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginWithFacebook;
@property (strong, nonatomic) DareDataStore *dataStore;
@end

@implementation LogInWithFacebookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataStore = [DareDataStore sharedDataStore];
    [_loginWithFacebook addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [_loginWithFacebook setTitleColor:[UIColor DareBlue] forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor DareBlue];
}

-(void)login
{
    [ParseClient loginWithFB:^(BOOL isNEW) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        if (isNEW) {
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
            NSLog(@"Returning");
            [ParseClient relateFacebookFriendsInParse:^(bool isDone) {
                if (isDone) {
                    [self.dataStore populateCoreData:^{
                        UINavigationController *nav = [storyboard instantiateViewControllerWithIdentifier:@"MainNavController"];
                        [self presentViewController:nav animated:YES completion:nil];
                    }];
                }
            } failure:nil];
        }
    }];
}


@end
