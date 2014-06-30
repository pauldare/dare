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

@interface FriendsListViewController ()<UICollectionViewDelegate>

@property (strong, nonatomic) UINib *friendNib;
@property (strong, nonatomic) UINib *finalCellNib;
@property (strong, nonatomic) NSSet *selectedFriends;
@property (strong, nonatomic) NSMutableSet *selectedIndices;
@property (strong, nonatomic) NSMutableArray *friends;

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
    _selectedFriends = [[NSSet alloc]init];
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
        
//        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
//        [queue addOperationWithBlock:^{
//            
//            NSURL *imageURL = [NSURL URLWithString:@"http://www.trutv.com/library/crime/blog/files/2013/03/p-april-vasturo-mugshot.jpg"];
//            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//            UIImage *image = [UIImage imageWithData:imageData];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                ((FriendListIcon*)cell).friendImage.image = image;
//                
//                
//            });
//            
//            
//        }];
        
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
#warning insert friends into set here
    
    if (![_selectedIndices containsObject:@(indexPath.row)]) {
        [_selectedIndices addObject:@(indexPath.row)];
    }else{
        [_selectedIndices removeObject:@(indexPath.row)];
    }
    [collectionView reloadData];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
