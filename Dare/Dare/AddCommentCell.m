//
//  AddCommentCell.m
//  Dare
//
//  Created by Nadia on 7/5/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "AddCommentCell.h"
#import "UIColor+DareColors.h"

@implementation AddCommentCell

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor DareBlue];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont boldSystemFontOfSize:18];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.text = @"I DARE\n COMMENT";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
