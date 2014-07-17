//
//  MessageCell.m
//  Dare
//
//  Created by Nadia on 7/5/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "MessageCell.h"
#import "UIColor+DareColors.h"
#import <QuartzCore/CALayer.h>

@implementation MessageCell

@synthesize imageView;
@synthesize textLabel;

- (void)awakeFromNib
{
    self.centeredUserPic.layer.cornerRadius = 25;
    self.centeredUserPic.layer.masksToBounds = YES;
    [self setupView];
}

- (void)setupView
{
    self.textView.backgroundColor = [UIColor DareBlue];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont boldSystemFontOfSize:18];
    self.textLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor DareBlue];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
