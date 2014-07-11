//
//  SplashVC.m
//  Dare
//
//  Created by Nadia on 7/7/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "SplashVC.h"
#import "UIColor+DareColors.h"

@interface SplashVC ()
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation SplashVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.coverView.backgroundColor = [UIColor DareCellOverlay];
}



@end
