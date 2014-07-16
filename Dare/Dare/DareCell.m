//
//  DareCell.m
//  Dare
//
//  Created by Test on 6/29/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "DareCell.h"
#import "UIColor+DareColors.h"

@interface DareCell()

@property (weak, nonatomic) IBOutlet UIView *cellContainerView;


@end

@implementation DareCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellContainerView.backgroundColor = [UIColor DareCellOverlay];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _unreadCountLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _backgroundImageView.backgroundColor = [UIColor DareBlue];
        self.backgroundColor = [UIColor DareBlue];
    }
    return self;
}

- (void)awakeFromNib
{
     self.cellContainerView.backgroundColor = [UIColor DareCellOverlay];
    _cellContainerView.backgroundColor = [UIColor DareCellOverlay];
    _backgroundImageView.backgroundColor = [UIColor clearColor];
    _unreadCountLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _titleLabel.textColor = [UIColor whiteColor];
    _unreadCountLabel.font = [UIFont boldSystemFontOfSize:48];
    _unreadCountLabel.textColor = [UIColor DareUnreadBadge];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
