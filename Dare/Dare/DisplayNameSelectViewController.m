//
//  DisplayNameSelectViewController.m
//  Dare
//
//  Created by Test on 6/29/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "DisplayNameSelectViewController.h"
#import "UIColor+DareColors.h"
#import "User.h"
#import "DareDataStore.h"
#import "MainScreenViewController.h"
#import "SettingsViewController.h"

@interface DisplayNameSelectViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextfield;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;
@property (strong, nonatomic) PFUser *loggedUser;
@property (strong, nonatomic) User *coreDataUser;
@property (strong, nonatomic) DareDataStore *dataStore;

@end

@implementation DisplayNameSelectViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view removeConstraints:self.view.constraints];
    self.dataStore = [DareDataStore sharedDataStore];
    [self fetchLoggedUser:^{}];
    self.view.backgroundColor = [UIColor DareBlue];
    self.loggedUser = [PFUser currentUser];
    self.userNameTextfield.text = self.loggedUser[@"displayName"];
    
    self.userNameTextfield.delegate = self;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *arrowTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(presentNextView)];
    arrowTapGesture.numberOfTapsRequired =1;
    [_arrowLabel addGestureRecognizer:arrowTapGesture];
    
    UITapGestureRecognizer *nextTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(presentNextView)];
    nextTapGesture.numberOfTapsRequired =1;
    [_nextLabel addGestureRecognizer:arrowTapGesture];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(presentNextView)];
    [swipeGesture requireGestureRecognizerToFail:tapGesture];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    
        
    _userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _userNameTextfield.translatesAutoresizingMaskIntoConstraints = NO;
    _nextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _arrowLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nextLabel.textAlignment = NSTextAlignmentRight;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userNameTextfield attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userNameTextfield attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userNameTextfield attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userNameTextfield attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:50.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userNameLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_userNameTextfield attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userNameLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userNameLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userNameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_userNameTextfield attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_arrowLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_arrowLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_arrowLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:80.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_arrowLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:100]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_nextLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_arrowLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_nextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_arrowLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_nextLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_arrowLabel attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_nextLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_arrowLabel attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
}


- (void)fetchLoggedUser: (void(^)())completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    self.coreDataUser = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil][0];
    completion();
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignFirstResponder];
    return YES;
}

- (BOOL)resignFirstResponder
{
    [self.userNameTextfield resignFirstResponder];
    [self.loggedUser setObject:_userNameTextfield.text forKey:@"displayName"];
    [self.loggedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.coreDataUser.displayName = self.userNameTextfield.text;
        [self.dataStore saveContext];
    }];
    return [super resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard
{
    [_userNameTextfield resignFirstResponder];
}

-(void)presentNextView
{
    if (![_userNameTextfield.text isEqual:@""]) {
        if (!self.fromSettings) {
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChooseDisplayPhoto"];
                [self presentViewController:vc animated:YES completion:nil];
        } else {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            UINavigationController *mainScreenNavController = [storyBoard instantiateViewControllerWithIdentifier:@"MainNavController"];
            MainScreenViewController *mainScreen = mainScreenNavController.viewControllers[0];
            mainScreen.fromCancel = NO;
            mainScreen.fromNew = YES;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
            mainScreen.threads = [[NSMutableArray alloc]initWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
            [self presentViewController:mainScreenNavController animated:YES completion:nil];
        }
    }    
}


@end
