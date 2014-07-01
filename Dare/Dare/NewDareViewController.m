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
#import "CameraManager.h"
#import "FriendListIcon.h"


@interface NewDareViewController () <UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CameraManager *cameraManager;

@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollection;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (weak, nonatomic) IBOutlet UICollectionView *textCollection;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *messages;


@end

@implementation NewDareViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cameraManager = [[CameraManager alloc]init];
    _imageView.backgroundColor = [UIColor DareBlue];
    _cameraView.backgroundColor = [UIColor DareBlue];
    
    self.friendsCollection.delegate = self;
    self.textCollection.delegate = self;
    self.friendsCollection.dataSource = self;
    self.textCollection.dataSource = self;
    
    self.images = @[[UIImage imageNamed:@"angry.jpeg"], [UIImage imageNamed:@"tricolor.jpeg"], [UIImage imageNamed:@"kitten.jpeg"], [UIImage imageNamed:@"cat.jpeg"]];
    
    self.messages = @[@"i like cats", @"i like icecream", @"i like fun"];
    
    UINib *friendNib = [UINib nibWithNibName:@"FriendListIcon" bundle:nil];
    [self.friendsCollection registerNib:friendNib forCellWithReuseIdentifier:@"FriendCell"];

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.friendsCollection) {
        return [self.images count];
    } else {
        return [self.messages count];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView == self.friendsCollection) {
        FriendListIcon *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
        ((FriendListIcon*)cell).friendImage.image = self.images[indexPath.row];
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"messageCell" forIndexPath:indexPath];
        return cell;
    }

}





@end
