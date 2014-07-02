//
//  SelectDareCell.m
//  Dare
//
//  Created by Nadia Yudina on 7/1/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "SelectDareCell.h"
#import "UIColor+DareColors.h"

@implementation SelectDareCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


- (void)awakeFromNib
{
    [self addSubview:self.forwardButton];
    [self addSubview:self.backButton];
    [self bringSubviewToFront:self.forwardButton];
    [self bringSubviewToFront:self.backButton];
}





@end
