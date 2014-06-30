//
//  NewDareViewController.m
//  Dare
//
//  Created by Nadia Yudina on 6/30/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "NewDareViewController.h"
#import "CameraManager.h"
#import "UIColor+DareColors.h"


@interface NewDareViewController ()

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CameraManager *cameraManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation NewDareViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cameraManager = [[CameraManager alloc]init];
    _imageView.backgroundColor = [UIColor DareBlue];
    _cameraView.backgroundColor = [UIColor DareBlue];
    
    self.tableView.rowHeight = self.view.bounds.size.width/3;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1.5707963);
    self.tableView.transform = transform;
    self.tableView.backgroundColor = [UIColor greenColor];
}



@end
