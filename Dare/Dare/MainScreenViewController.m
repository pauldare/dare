//
//  MainScreenViewController.m
//  Dare
//
//  Created by Dare on 7/1/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "MainScreenViewController.h"
#import "User.h"
#import "UIColor+DareColors.h"
#import "ParseClient.h"
#import "FriendListIcon.h"
#import "FinalCell.h"
#import "NewDareViewController.h"
#import "DareCell.h"

@interface MainScreenViewController ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UINib *friendNib;
@property (strong, nonatomic) UINib *finalCellNib;
@property (strong, nonatomic) NSMutableSet *selectedFriends;
@property (strong, nonatomic) NSMutableSet *selectedIndices;
@property (strong, nonatomic) NSMutableArray *friends;
@property (nonatomic) BOOL isArrow;
@property (strong, nonatomic) UINib *cellNib;
@property (strong, nonatomic) NSArray *threads;
@property (strong, nonatomic) User *loggedUser;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MainScreenViewController

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
    [_collectionView registerNib:_friendNib forCellWithReuseIdentifier:@"FriendCell"];
    
    _finalCellNib = [UINib nibWithNibName:@"FinalCell" bundle:nil];
    [_collectionView registerNib:_finalCellNib forCellWithReuseIdentifier:@"FinalCell"];

    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor DareBlue];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
#warning Remove this! It's for testing
    _friendsArray = @[@1, @2, @3, @4, @5, @6];
    _selectedFriends = [[NSMutableSet alloc]init];
    _selectedIndices = [[NSMutableSet alloc]init];
    
    _tableView.backgroundColor = [UIColor DareBlue];
    
    _cellNib = [UINib nibWithNibName:@"DareCell" bundle:nil];
    [_tableView registerNib:_cellNib forCellReuseIdentifier:@"DareCell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [ParseClient getUser:[PFUser currentUser] completion:^(User *loggedUser) {
        _loggedUser = loggedUser;
        
        [ParseClient getMessageThreadsForUser:self.loggedUser completion:^(NSArray *threads, bool isDone) {
            if (isDone) {
                _threads = threads;
                //[self.tableView reloadData];
                for (MessageThread *thread in _threads) {
                    [ParseClient getMessagesForThread:thread user:loggedUser completion:^(NSArray *messages) {
                        thread.unreadMessages = 0;
                        for (Message *message in messages) {
                            if (!message.isRead) {
                                thread.unreadMessages++;
                            }
                        }
                        [_tableView reloadData];
                    } failure:nil];
                }
            }
        } failure:nil];
    } failure:nil];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //this adds a final selection cell
    //return 50;
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
        viewController.friends = [self.selectedFriends allObjects];
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 50;
    return [self.threads count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 112.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DareCell" forIndexPath:indexPath];
    
//    MessageThread *thread = self.threads[indexPath.row];
//    ((DareCell *)cell).backgroundImageView.image = thread.backgroundImage;
//    ((DareCell *)cell).titleLabel.text = [NSString stringWithFormat:@"I DARE YOU TO\n%@", thread.title];
//    ((DareCell *)cell).unreadCountLabel.text = [NSString stringWithFormat:@"%ld", (long)thread.unreadMessages];
    
    
    ((DareCell *)cell).unreadCountLabel.text = @"6";
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [queue addOperationWithBlock:^{
    
            NSURL *imageURL = [NSURL URLWithString:@"http://ibmsmartercommerce.sourceforge.net/wp-content/uploads/2012/09/Roses_Bunch_Of_Flowers.jpeg"];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
    
            dispatch_async(dispatch_get_main_queue(), ^{
                ((DareCell *)cell).backgroundImageView.image = image;
                ((DareCell *)cell).titleLabel.text = @"I DARE YOU TO WEAR PINK" ;
                ((DareCell *)cell).unreadCountLabel.text = @"15";
            });
        }];
    
    return cell;
}




@end
