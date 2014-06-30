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

@interface DisplayNameSelectViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextfield;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;
@property (strong, nonatomic) PFUser *loggedUser;

@end

@implementation DisplayNameSelectViewController

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
    [self.view removeConstraints:self.view.constraints];
    
    self.view.backgroundColor = [UIColor DareBlue];
    self.loggedUser = [PFUser currentUser];
    self.userNameTextfield.text = self.loggedUser[@"displayName"];
    
    self.userNameTextfield.delegate = self;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
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
    
    
    // Do any additional setup after loading the view.
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
    [self.loggedUser saveInBackground];
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
