//
//  HeaderCell.m
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "HeaderCell.h"
#import "FriendListIcon.h"
#import "Friend.h"
#import "UIColor+DareColors.h"
#import <QuartzCore/CALayer.h>


@interface HeaderCell ()

@property (strong, nonatomic) DareDataStore *dataStore;
@property (strong, nonatomic) NSArray *images;


@end


@implementation HeaderCell

@synthesize textLabel;

- (void)awakeFromNib
{
    self.images = @[[UIImage imageNamed:@"angry.jpeg"], [UIImage imageNamed:@"tricolor.jpeg"], [UIImage imageNamed:@"kitten.jpeg"], [UIImage imageNamed:@"cat.jpeg"]];
    self.textLabel.backgroundColor = [UIColor blackColor];
    self.dataStore = [DareDataStore sharedDataStore];
    [self setupViews];
    [self fetchFriends:^{
        [self.collectionView reloadData];
    }];
    UINib *friendNib = [UINib nibWithNibName:@"FriendListIcon" bundle:nil];
    [self.collectionView registerNib:friendNib forCellWithReuseIdentifier:@"FriendCell"];
}

- (void)setupViews
{
    UIImage *flowerImage = [UIImage imageNamed:@"flower.jpeg"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont boldSystemFontOfSize:18];
    self.textLabel.textColor = [UIColor whiteColor];
    self.mainImage.image = flowerImage;
    self.collectionView.backgroundColor = [UIColor DareBlue];
    self.dareView.backgroundColor = [UIColor DareCellOverlay];
    self.userImage.layer.cornerRadius = 25;
    self.userImage.layer.masksToBounds = YES;
    self.userImage.image = self.images[0];
}

- (void)fetchFriends: (void(^)())completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    self.friends = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    completion();
}


#pragma collection view delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 50;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat oneThirdOfDisplay = self.collectionView.frame.size.width/3;
    return CGSizeMake(oneThirdOfDisplay, collectionView.frame.size.height);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return -1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return -1.0;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FriendListIcon *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
    //UIImage *image = self.images[indexPath.row];
//    Friend *friend = self.friends[indexPath.row];
    Friend *friend = self.friends[0];
    UIImage *image = [UIImage imageWithData:friend.image];
    ((FriendListIcon *)cell).friendImage.image = image;
    return cell;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
