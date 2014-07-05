//
//  MessageCell.m
//  Dare
//
//  Created by Nadia on 7/5/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "MessageCell.h"
#import "UIColor+DareColors.h"

@implementation MessageCell

@synthesize imageView;
@synthesize textLabel;

- (void)awakeFromNib
{
    UIImage *shoes = [UIImage imageNamed:@"shoes.jpeg"];
    UIImage *cat = [UIImage imageNamed:@"cat.jpeg"];
    self.imageView.image = shoes;
    self.userPic.image = cat;
    [self setupView];
}

- (void)setupView
{
    self.textView.backgroundColor = [UIColor DareBlue];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont boldSystemFontOfSize:18];
    self.textLabel.textColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
