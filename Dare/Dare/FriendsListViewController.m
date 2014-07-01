//
//  FriendsListViewController.m
//  Dare
//
//  Created by Test on 6/29/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "FriendsListViewController.h"
#import "FriendListIcon.h"
#import "UIColor+DareColors.h"
#import "FinalCell.h"
#import "User.h"
#import "ParseClient.h"
#import "NewDareViewController.h"

@interface FriendsListViewController ()<UICollectionViewDelegate>

@property (strong, nonatomic) UINib *friendNib;
@property (strong, nonatomic) UINib *finalCellNib;
@property (strong, nonatomic) NSMutableSet *selectedFriends;
@property (strong, nonatomic) NSMutableSet *selectedIndices;
@property (strong, nonatomic) NSMutableArray *friends;
@property (nonatomic) BOOL isArrow;

@end

@implementation FriendsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.friends = [[NSMutableArray alloc]init];
    self.isArrow = NO;
    
    [ParseClient getUser:[PFUser currentUser] completion:^(User *loggedUser) {
        for (PFUser *friend in loggedUser.friends) {
            [ParseClient getUser:friend completion:^(User *friend) {
                [self.friends addObject:friend];
                [self.collectionView reloadData];
            } failure:nil];
        }
    } failure:nil];
    
    _friendNib = [UINib nibWithNibName:@"FriendListIcon" bundle:nil];
    [self.collectionView registerNib:_friendNib forCellWithReuseIdentifier:@"FriendCell"];
    
    _finalCellNib = [UINib nibWithNibName:@"FinalCell" bundle:nil];
    [self.collectionView registerNib:_finalCellNib forCellWithReuseIdentifier:@"FinalCell"];
    
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor DareBlue];
    
#warning Remove this! It's for testing
    _friendsArray = @[@1, @2, @3, @4, @5, @6];
    _selectedFriends = [[NSMutableSet alloc]init];
    _selectedIndices = [[NSMutableSet alloc]init];
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //this adds a final selection cell
//    return [_friendsArray count] +1;
    return [self.friends count] + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
   
    if (indexPath.row == [self.friends count]) {
        
        FinalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FinalCell" forIndexPath:indexPath];
        cell.cellLabel.backgroundColor = [UIColor DareBlue];
        if ([_selectedIndices count] == 0) {
            cell.cellLabel.font = [UIFont boldSystemFontOfSize:120];
            cell.cellLabel.text = @"＋";
            
        }else{
            cell.cellLabel.font = [UIFont boldSystemFontOfSize:80];
            cell.cellLabel.text = @"➡︎";
            self.isArrow = YES;
        }

        return cell;
        
    }else{
         FriendListIcon *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
        
        if ([_selectedIndices containsObject:@(indexPath.row)]) {
            cell.selectedOverlay.backgroundColor = [UIColor DareOverlaySeletcedCell];
        }else{
            cell.selectedOverlay.backgroundColor = [UIColor clearColor];
        }
        
        User *friend = self.friends[indexPath.row];
        ((FriendListIcon*)cell).friendImage.image = friend.profileImage;
        
        return cell;
    }
    
    return nil;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat oneThirdOfDisplay = self.collectionView.frame.size.width/3;
    return CGSizeMake(oneThirdOfDisplay, oneThirdOfDisplay);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (![_selectedIndices containsObject:@(indexPath.row)]) {
        [_selectedIndices addObject:@(indexPath.row)];
    }else{
        [_selectedIndices removeObject:@(indexPath.row)];
    }
    [collectionView reloadData];
    
    for (NSNumber *index in _selectedIndices) {
        if ([index integerValue] < [self.friends count]) {
            [self.selectedFriends addObject:[self.friends objectAtIndex:[index integerValue]]];
        }
    }
    
    NSLog(@"%@", self.selectedFriends);
    
    if (indexPath.row == [self.friends count] && self.isArrow) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        NewDareViewController *viewController = (NewDareViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NewDare"];
        viewController.friends = self.selectedFriends;
        [self presentViewController:viewController animated:YES completion:nil];
    }    
}



@end
