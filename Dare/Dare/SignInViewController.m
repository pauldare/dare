//
//  SignInViewController.m
//  Dare
//
//  Created by Dare on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "SignInViewController.h"
#import "LogInWithFacebookViewController.h"
#import "UIColor+DareColors.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

@interface SignInViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;
@property (weak, nonatomic) IBOutlet UILabel *signinLabel;

@end

@implementation SignInViewController

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
    
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor DareBlue];
    
    FAKFontAwesome *rightLabel = [FAKFontAwesome forwardIconWithSize:48];
    NSMutableAttributedString *rightMutString = [[NSMutableAttributedString alloc]init];
    [rightMutString appendAttributedString:[rightLabel attributedString]];
    [rightMutString appendAttributedString:[rightLabel attributedString]];
    
    _arrowLabel.attributedText = rightMutString;

    
    UITapGestureRecognizer *tapOnArrow = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(segueToFacebookLogInVC)];
    tapOnArrow.numberOfTapsRequired = 1;
    [self.arrowLabel addGestureRecognizer:tapOnArrow];
    self.arrowLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapOnSignIn = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(segueToFacebookLogInVC)];
    tapOnSignIn.numberOfTapsRequired = 1;
    [self.signinLabel addGestureRecognizer:tapOnSignIn];
    self.signinLabel.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *swipeLeftOnScreen = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(segueToFacebookLogInVC)];
    [swipeLeftOnScreen requireGestureRecognizerToFail:tapOnSignIn];
    [swipeLeftOnScreen requireGestureRecognizerToFail:tapOnArrow];
    swipeLeftOnScreen.cancelsTouchesInView = NO;
    swipeLeftOnScreen.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftOnScreen];
    
        

    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)segueToFacebookLogInVC
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    LogInWithFacebookViewController *facebookVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"LogInWithFaceBookVC"];
    [self.navigationController pushViewController:facebookVC animated:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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
