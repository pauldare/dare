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
#import "DareDataStore.h"
#import "User+Methods.h"
#import "ChooseDisplayPhotoViewController.h"
#import "DisplayNameSelectViewController.h"


@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *changePictureLabel;
@property (weak, nonatomic) IBOutlet UIButton *unblockButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;
@property (weak, nonatomic) IBOutlet UILabel *backArrowLabel;
@property (strong, nonatomic) DareDataStore *dataStore;
@property (strong, nonatomic) User *loggedUser;


@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataStore = [DareDataStore sharedDataStore];
    [self fetchLoggedUser:^{
        UIImage *photo = [UIImage imageWithData:self.loggedUser.profileImage];
        self.profilePhoto.image = photo;
    }];
    self.view.backgroundColor = [UIColor DareBlue];

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
}

- (void)fetchLoggedUser: (void(^)())completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    self.loggedUser = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil][0];
    completion();
}

- (IBAction)changeImageButtonPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    ChooseDisplayPhotoViewController *viewController = (ChooseDisplayPhotoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChooseDisplayPhoto"];
    viewController.fromSettings = YES;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)changeNameButton:(id)sender
{    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    DisplayNameSelectViewController *viewController = (DisplayNameSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DisplayNameSelectVC"];
    viewController.fromSettings = YES;
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)backToMainPage
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UINavigationController *mainScreenNavController = [storyBoard instantiateViewControllerWithIdentifier:@"MainNavController"];
    MainScreenViewController *mainScreen = mainScreenNavController.viewControllers[0];
    mainScreen.fromCancel = NO;
    mainScreen.fromNew = YES;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
    mainScreen.threads = [[NSMutableArray alloc]initWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
    [self presentViewController:mainScreenNavController animated:YES completion:nil];
}

-(void)unblockUsers
{
#warning present unblocking VC here
}

-(void)logOut
{
#warning add logout code
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    [PFUser logOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UINavigationController *initialNavController = [storyboard instantiateViewControllerWithIdentifier:@"InitialNavController"];
    [self presentViewController:initialNavController animated:YES completion:nil];
}


@end
