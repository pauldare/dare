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

@interface MainScreenViewController ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIView *mainOverlay;
@property (nonatomic) CGFloat collectionViewSquareSize;
@property (strong, nonatomic) UIButton *friendsCornerButton;
@property (weak, nonatomic) IBOutlet UIView *scrollContainerView;
@property (strong, nonatomic) UILabel *dareLabel;
@property (strong, nonatomic) UIView *centerLine;
@property (strong, nonatomic) UILabel *dareLabelRightArrows;
@property (strong, nonatomic) UILabel *dareLabelLeftArrows;
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
    
    _collectionViewSquareSize = _collectionView.frame.size.width/3;
    _scrollView.contentSize = CGSizeMake(_collectionView.frame.size.width + _tableView.frame.size.width + 5, _scrollView.frame.size.height);
    [_scrollView setContentOffset:CGPointMake(_collectionView.frame.size.width/2, 0)];
    
    _mainOverlay = [[UIView alloc]initWithFrame:self.view.frame];
    _mainOverlay.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    [self.view addSubview:_mainOverlay];
    _mainOverlay.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *rightSwipeOnMainView = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeOnOverlay)];
    rightSwipeOnMainView.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeOnMainView.numberOfTouchesRequired = 1;
    rightSwipeOnMainView.delegate = self;
    [_mainOverlay addGestureRecognizer:rightSwipeOnMainView];
    
    _dareLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 130, 50)];
    [_dareLabel setCenter:CGPointMake(_mainOverlay.center.x, _mainOverlay.center.y)];
    _dareLabel.text = @"DARE";
    _dareLabel.textAlignment = NSTextAlignmentCenter;
    _dareLabel.backgroundColor = [UIColor DareBlue];
    _dareLabel.font = [UIFont boldSystemFontOfSize:40];
    _dareLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_dareLabel];
    
    
    _centerLine = [[UIView alloc]initWithFrame:CGRectMake(self.view.center.x - 5, 0, 10.0, self.view.frame.size.height)];
    _centerLine .backgroundColor = [UIColor DareBlue];
    [self.view addSubview:_centerLine];
    [self.view bringSubviewToFront:_dareLabel];
    
    _dareLabelRightArrows = [[UILabel alloc]initWithFrame:CGRectMake(_dareLabel.center.x + (_dareLabel.frame.size.width/2) -12, _dareLabel.frame.origin.y-4, (_mainOverlay.frame.size.width/2)+10 - (_dareLabel.frame.size.width/2), _dareLabel.frame.size.height+10)];
    _dareLabelRightArrows.text = @"▶︎▶︎";
    _dareLabelRightArrows.font = [UIFont boldSystemFontOfSize:52];
    _dareLabelRightArrows.textAlignment = NSTextAlignmentLeft;
    _dareLabelRightArrows.textColor = [UIColor DareBlue];
    [self.view addSubview:_dareLabelRightArrows];
    
    _dareLabelLeftArrows = [[UILabel alloc]initWithFrame:CGRectMake(_dareLabel.center.x - (_dareLabel.frame.size.width/2) -93, _dareLabel.frame.origin.y-4, (_mainOverlay.frame.size.width/2)+10 - (_dareLabel.frame.size.width/2), _dareLabel.frame.size.height+10)];
    _dareLabelLeftArrows.text = @"◀︎◀︎";
    _dareLabelLeftArrows.font = [UIFont boldSystemFontOfSize:52];
    _dareLabelLeftArrows.textAlignment = NSTextAlignmentLeft;
    _dareLabelLeftArrows.textColor = [UIColor DareBlue];
    [self.view addSubview:_dareLabelLeftArrows];

    UISwipeGestureRecognizer *leftSwipeOnMainView = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipeOnOverlay)];
    leftSwipeOnMainView.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeOnMainView.numberOfTouchesRequired = 1;
    leftSwipeOnMainView.delegate = self;
    [_mainOverlay addGestureRecognizer:leftSwipeOnMainView];
    
    UISwipeGestureRecognizer *rightSwipeOnThreadList = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeOnThreadList)];
    rightSwipeOnThreadList.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeOnThreadList.numberOfTouchesRequired = 1;
    rightSwipeOnThreadList.delegate = self;
    [_tableView addGestureRecognizer:rightSwipeOnThreadList];
    
    
    UISwipeGestureRecognizer *leftSwipeOnFriendsList = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipeOnFriendsList)];
    leftSwipeOnFriendsList.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeOnFriendsList.numberOfTouchesRequired = 1;
    leftSwipeOnFriendsList.delegate = self;
    [_collectionView addGestureRecognizer:leftSwipeOnFriendsList];
    
    _friendsCornerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _friendsCornerButton.backgroundColor = [UIColor clearColor];
    _friendsCornerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_friendsCornerButton setTitle:@"➡︎" forState:UIControlStateNormal];
    _friendsCornerButton.titleLabel.font = [UIFont systemFontOfSize:100];
    [_friendsCornerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_scrollContainerView addSubview:_friendsCornerButton];
    
    [_scrollContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_friendsCornerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:_collectionViewSquareSize]];
     [_scrollContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_friendsCornerButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:_collectionViewSquareSize]];
     [_scrollContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_friendsCornerButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [_scrollContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_friendsCornerButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    
    
    
    
    NSLog(@"%f", _collectionView.frame.size.width);
    NSLog(@"%f", _scrollView.contentSize.width);

    _scrollView.scrollEnabled = NO;
    
    _friends = [[NSMutableArray alloc]init];
    _isArrow = NO;
    
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
    _tableView.bounces = NO;
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

-(void)rightSwipeOnOverlay
{
    //[_scrollView setContentOffset:CGPointMake(0, 0)];
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
 [UIView animateWithDuration:0.2 animations:^{
     _mainOverlay.alpha = 0;
     _dareLabel.alpha = 0;
     _centerLine.alpha = 0;
 } completion:^(BOOL finished) {
     _mainOverlay.hidden = YES;
     _dareLabel.hidden = YES;
     _centerLine.hidden = YES;
 }];
}

-(void)leftSwipeOnOverlay
{
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentSize.width - _tableView.frame.size.width, 0) animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        _mainOverlay.alpha = 0;
        _dareLabel.alpha = 0;
        _centerLine.alpha = 0;
    } completion:^(BOOL finished) {
        _mainOverlay.hidden = YES;
        _dareLabel.hidden = YES;
        _centerLine.hidden = YES;
    }];

}

-(void)rightSwipeOnThreadList
{
    [_scrollView setContentOffset:CGPointMake(_collectionView.frame.size.width/2, 0) animated:YES];
    
    _mainOverlay.hidden = NO;
    _dareLabel.hidden = NO;
    _centerLine.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _mainOverlay.alpha = 0.8;
        [_mainOverlay bringSubviewToFront:_dareLabel];
        _dareLabel.alpha = 1.0;
        _centerLine.alpha = 1.0;
    }];
}

-(void)leftSwipeOnFriendsList
{
    [_scrollView setContentOffset:CGPointMake(_collectionView.frame.size.width/2, 0) animated:YES];
    
    _mainOverlay.hidden = NO;
    _dareLabel.hidden = NO;
    _centerLine.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _mainOverlay.alpha = 0.8;
        [_mainOverlay bringSubviewToFront:_dareLabel];
        _dareLabel.alpha = 1.0;
        _centerLine.alpha = 1.0;
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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
        cell.backgroundColor = [UIColor clearColor];
        cell.cellLabel.text = @"";
        
//        cell.cellLabel.backgroundColor = [UIColor DareBlue];
//        if ([_selectedIndices count] == 0) {
//            cell.cellLabel.font = [UIFont boldSystemFontOfSize:120];
//            cell.cellLabel.text = @"＋";
//            
//        }else{
//            cell.cellLabel.font = [UIFont boldSystemFontOfSize:80];
//            cell.cellLabel.text = @"➡︎";
//            self.isArrow = YES;
//        }
        
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
    
    return CGSizeMake(_collectionViewSquareSize, _collectionViewSquareSize);
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
