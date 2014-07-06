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
        __block UIViewController *viewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        if (isNEW) {
            NSLog(@"I am new");
            [ParseClient relateFacebookFriendsInParse:^(bool isDone) {
                if (isDone) {
                    [self.dataStore populateCoreData:^{
                        viewController = [storyboard instantiateViewControllerWithIdentifier:@"DisplayNameSelectVC"];
                        [self presentViewController:viewController animated:YES completion:nil];
                    }];
                }
            } failure:nil];
        } else {
            NSLog(@"Returning");
            [ParseClient relateFacebookFriendsInParse:^(bool isDone) {
                if (isDone) {
                    [self.dataStore populateCoreData:^{
                        viewController = [storyboard instantiateViewControllerWithIdentifier:@"MainScreen"];
                        [self presentViewController:viewController animated:YES completion:nil];
                    }];
                }
            } failure:nil];
        }
        
    }];
}


@end
