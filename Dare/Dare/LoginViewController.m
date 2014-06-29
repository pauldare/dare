//
//  LoginViewController.m
//  Dare
//
//  Created by Dare Ryan on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "User.h"


@interface LoginViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *dareLabel;
@property (weak, nonatomic) IBOutlet UILabel *signinLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;





@end

@implementation LoginViewController

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
    
    UITapGestureRecognizer *signinGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollPage)];
    signinGesture.numberOfTapsRequired = 1;
    UITapGestureRecognizer *arrowGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollPage)];
    arrowGesture.numberOfTapsRequired = 1;

    [_arrowLabel addGestureRecognizer:arrowGesture];
    [_signinLabel addGestureRecognizer:signinGesture];
    _arrowLabel.userInteractionEnabled = YES;
    _signinLabel.userInteractionEnabled = YES;
    _scrollView.backgroundColor = [UIColor colorWithRed:0 green:0.84 blue:1.0 alpha:1.0];
    _containerView.backgroundColor = [UIColor colorWithRed:0 green:0.84 blue:1.0 alpha:1.0];
    _signinLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _arrowLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _scrollView.frame = self.view.frame;
    CGRect scrollFrame = _scrollView.frame;
    scrollFrame.size.width = scrollFrame.size.width * 2;
    _containerView.frame = scrollFrame;
    _dareLabel.center = CGPointMake(_scrollView.center.x, _scrollView.center.y);
    CGFloat arrowLabelBox = 100;
    _arrowLabel.frame = CGRectMake(_scrollView.frame.size.width - arrowLabelBox, _scrollView.frame.size.height - arrowLabelBox, arrowLabelBox, arrowLabelBox);
    CGFloat signinBox = 150;
    _signinLabel.frame = CGRectMake(_scrollView.frame.size.width - (arrowLabelBox+signinBox), _scrollView.frame.size.height - arrowLabelBox, signinBox, arrowLabelBox);
    
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    facebookButton.tintColor = [UIColor whiteColor];
    CGFloat buttonHeight = 90;
    facebookButton.frame = CGRectMake(_scrollView.frame.size.width, _scrollView.center.y - buttonHeight/2, _scrollView.frame.size.width, buttonHeight);
    facebookButton.backgroundColor = [UIColor clearColor];
    facebookButton.titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
    [facebookButton setTitle:@"Login with facebook" forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:facebookButton];
    
    
//    UILabel *loginWithFacebookLabel = [[UILabel alloc]init];
//    loginWithFacebookLabel.text = @"Login With Facebook";
//    loginWithFacebookLabel.frame = CGRectMake(_scrollView.frame.size.width, facebookButton.frame.origin.y - buttonHeight, _scrollView.frame.size.width, buttonHeight);
//    [_containerView addSubview:loginWithFacebookLabel];

    
    // Do any additional setup after loading the view.
}

-(void)login
{
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
                //NSLog(@"Currently loggen in: %@", [PFUser currentUser]);
                
                User *newUser = [User getUser];
                NSLog(@"%@, %@", newUser.displayName, newUser.friends);
                
                
            }
        }];
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _scrollView.contentSize = _containerView.frame.size;

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollPage
{
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
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
