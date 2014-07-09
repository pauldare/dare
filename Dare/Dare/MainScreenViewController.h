//
//  MainScreenViewController.h
//  Dare
//
//  Created by Dare on 7/1/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainScreenViewController : UIViewController

@property (strong, nonatomic) UIImage *friendImage;

@property (strong, nonatomic) NSArray *friendsArray;
@property (nonatomic) NSInteger unreadCount;
@property (nonatomic) BOOL fromCancel;

@property (strong, nonatomic) NSMutableArray *threads;

@end
