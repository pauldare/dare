//
//  FriendListIcon.h
//  Dare
//
//  Created by Test on 6/29/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendListIcon : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friendImage;
@property (nonatomic) BOOL indexIsSelected;
@property (weak, nonatomic) IBOutlet UIView *selectedOverlay;

@end
