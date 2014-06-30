//
//  DisplayNameSelectViewController.m
//  Dare
//
//  Created by Test on 6/29/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "DisplayNameSelectViewController.h"
#import "UIColor+DareColors.h"

@interface DisplayNameSelectViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextfield;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;

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
    
    self.view.backgroundColor = [UIColor DareBlue];
    
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
    
    
    // Do any additional setup after loading the view.
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
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChooseDisplayPhoto"];
        [self presentViewController:vc animated:YES completion:nil];
    }
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
