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

@interface LogInWithFacebookViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginWithFacebook;

@end

@implementation LogInWithFacebookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_loginWithFacebook addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [_loginWithFacebook setTitleColor:[UIColor DareBlue] forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor DareBlue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)login
{
    [ParseClient loginWithFB:^(BOOL isNEW) {
        UIViewController *viewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        if (isNEW) {
            NSLog(@"I am new");
            [ParseClient relateFacebookFriendsInParse:^(bool isDone) {
                
            } failure:nil];
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"DisplayNameSelectVC"];
            
        } else {
            NSLog(@"Returning");
            [ParseClient relateFacebookFriendsInParse:^(bool isDone) {
                
            } failure:nil];
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"MainScreen"];
        }
        [self presentViewController:viewController animated:YES completion:nil];
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
