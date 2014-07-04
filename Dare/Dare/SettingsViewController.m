//
//  SettingsViewController.m
//  Dare
//
//  Created by Dare on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+DareColors.h"
#import "ParseClient.h"
#import "SignInViewController.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "MainScreenViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *changePictureLabel;
@property (weak, nonatomic) IBOutlet UIButton *unblockButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;
@property (weak, nonatomic) IBOutlet UILabel *backArrowLabel;

@end

@implementation SettingsViewController

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
    
    self.view.backgroundColor = [UIColor DareBlue];
    
    [ParseClient getUser:[PFUser currentUser] completion:^(User *loggedUser) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _profilePhoto.image = loggedUser.profileImage;
        });
        
    } failure:nil];
    
    [_unblockButton addTarget:self action:@selector(unblockUsers) forControlEvents:UIControlEventTouchUpInside];
    
    [_logOutButton addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
    
    FAKFontAwesome *leftLabel = [FAKFontAwesome backwardIconWithSize:48];
    NSMutableAttributedString *leftMutString = [[NSMutableAttributedString alloc]init];
    [leftMutString appendAttributedString:[leftLabel attributedString]];
    [leftMutString appendAttributedString:[leftLabel attributedString]];
    _backArrowLabel.attributedText = leftMutString;
    
    [_logOutButton setTitleColor:[UIColor DareUnreadBadge] forState:UIControlStateNormal];

    UITapGestureRecognizer *tapOnArrow = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backToMainPage)];
    tapOnArrow.numberOfTapsRequired = 1;
    [_backArrowLabel addGestureRecognizer:tapOnArrow];
    _backArrowLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapOnBack = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backToMainPage)];
    tapOnBack.numberOfTapsRequired = 1;
    [_backLabel addGestureRecognizer:tapOnBack];
    _backLabel.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *swipeToGoBack = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backToMainPage)];
    swipeToGoBack.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeToGoBack];
    
    self.navigationController.navigationBarHidden = YES;
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backToMainPage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    MainScreenViewController *mainVC = [storyboard instantiateViewControllerWithIdentifier:@"MainScreen"];
    
    [self.navigationController popToViewController:mainVC animated:YES];

}

-(void)unblockUsers
{
#warning present unblocking VC here
}

-(void)logOut
{
#warning add logout code
   //[PFUser logOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
   UINavigationController *initialNavController = [storyboard instantiateViewControllerWithIdentifier:@"InitialNavController"];
    
    
    [self presentViewController:initialNavController animated:YES completion:nil];
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
