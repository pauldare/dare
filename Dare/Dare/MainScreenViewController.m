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
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "SettingsViewController.h"
#import "DareDataStore.h"
#import "Friend+Methods.h"
#import "MessagesTVC.h"

@interface MainScreenViewController ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UINib *friendNib;
@property (strong, nonatomic) UINib *finalCellNib;
@property (strong, nonatomic) NSMutableSet *selectedFriends;
@property (strong, nonatomic) NSMutableSet *selectedIndices;
@property (strong, nonatomic) NSArray *friends;
@property (nonatomic) BOOL isArrow;
@property (strong, nonatomic) UINib *cellNib;
@property (strong, nonatomic) NSArray *threads;
@property (strong, nonatomic) User *loggedUser;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIView *mainOverlay;
@property (nonatomic) CGFloat collectionViewFriendWidth;
@property (nonatomic) CGFloat collectionViewFriendHeight;
@property (strong, nonatomic) UIButton *friendsCornerButton;
@property (weak, nonatomic) IBOutlet UIView *scrollContainerView;
@property (strong, nonatomic) UILabel *dareLabel;
@property (strong, nonatomic) UIView *centerLine;
@property (strong, nonatomic) UILabel *dareLabelRightArrows;
@property (strong, nonatomic) UILabel *dareLabelLeftArrows;
@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UILabel *overlayUnreadBadge;
@property (strong, nonatomic) UIImage *testFriendImage;
@property (strong, nonatomic) UIRefreshControl *tableViewRefreshControl;
@property (strong, nonatomic) UIRefreshControl *collectionViewRefreshControl;
@property (strong, nonatomic) DareDataStore *dataStore;

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
    
    self.dataStore = [DareDataStore sharedDataStore];
    
    _tableViewRefreshControl = [[UIRefreshControl alloc] init];
    [_tableViewRefreshControl addTarget:self action:@selector(refreshFeeds) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_tableViewRefreshControl];
    
    _collectionViewRefreshControl = [[UIRefreshControl alloc]init];
    [_collectionViewRefreshControl addTarget:self action:@selector(refreshFriends) forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_collectionViewRefreshControl];
    
    
    NSURL *imageURL = [NSURL URLWithString:@"http://ibmsmartercommerce.sourceforge.net/wp-content/uploads/2012/09/Roses_Bunch_Of_Flowers.jpeg"];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    _testFriendImage = [UIImage imageWithData:imageData];
    
    _collectionView.alwaysBounceVertical = YES;
    _collectionViewFriendWidth= _collectionView.frame.size.width/3;
    
    _collectionViewFriendHeight = self.view.frame.size.height/5;
    _scrollView.contentSize = CGSizeMake(_collectionView.frame.size.width + _tableView.frame.size.width, _scrollView.frame.size.height);
    //[_scrollView setContentOffset:CGPointMake(_collectionView.frame.size.width/2, 0)];
    
    UISwipeGestureRecognizer *rightSwipeOnThreadList = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(scrollToMainScreen)];
    rightSwipeOnThreadList.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeOnThreadList.numberOfTouchesRequired = 1;
    rightSwipeOnThreadList.delegate = self;
    [_tableView addGestureRecognizer:rightSwipeOnThreadList];
    
    
    UISwipeGestureRecognizer *leftSwipeOnFriendsList = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                                                                action:@selector(scrollToMainScreen)];
    leftSwipeOnFriendsList.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeOnFriendsList.numberOfTouchesRequired = 1;
    leftSwipeOnFriendsList.delegate = self;
    [_collectionView addGestureRecognizer:leftSwipeOnFriendsList];
    
    
    _friendsCornerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _friendsCornerButton.backgroundColor = [UIColor DareBlue];
    [_friendsCornerButton addTarget:self action:@selector(friendsCornerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _friendsCornerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_friendsCornerButton setTitle:@"＋" forState:UIControlStateNormal];
    _friendsCornerButton.titleLabel.font = [UIFont systemFontOfSize:100];
    [_friendsCornerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_scrollContainerView addSubview:_friendsCornerButton];
    
    [_scrollContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_friendsCornerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:_collectionViewFriendHeight]];
    [_scrollContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_friendsCornerButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:_collectionViewFriendWidth]];
    [_scrollContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_friendsCornerButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [_scrollContainerView addConstraint:[NSLayoutConstraint constraintWithItem:_friendsCornerButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
 
    NSLog(@"%f", _collectionView.frame.size.width);
    NSLog(@"%f", _scrollView.contentSize.width);
    
    _scrollView.scrollEnabled = NO;
    
    _friends = [[NSMutableArray alloc]init];
    _isArrow = NO;
    
    
    _friendNib = [UINib nibWithNibName:@"FriendListIcon" bundle:nil];
    [_collectionView registerNib:_friendNib forCellWithReuseIdentifier:@"FriendCell"];
    
    _finalCellNib = [UINib nibWithNibName:@"FinalCell" bundle:nil];
    [_collectionView registerNib:_finalCellNib forCellWithReuseIdentifier:@"FinalCell"];

    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor DareBlue];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;

    _selectedFriends = [[NSMutableSet alloc]init];
    _selectedIndices = [[NSMutableSet alloc]init];
    
    _tableView.backgroundColor = [UIColor DareBlue];
    
    _cellNib = [UINib nibWithNibName:@"DareCell" bundle:nil];
    [_tableView registerNib:_cellNib forCellReuseIdentifier:@"DareCell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self fetchFriends:^{
        [self.collectionView reloadData];
    }];
    
    [self fetchthreads:^{
        [self.tableView reloadData];
    }];
    
    [self configureMainScreen];
}


- (void)fetchFriends: (void(^)())completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    self.friends = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    completion();
}

- (void)fetchthreads: (void(^)())completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
    self.threads = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    completion();
}



- (NSInteger)countTotalUnread
{
    NSInteger total = 0;
    for (MessageThread *thread in self.threads) {
        for (Message *message in thread.messages) {
            if ([message.isRead integerValue] == 0) {
                total++;
            }
        }
    }
    return total;
}


-(void)refreshFeeds
{
    
    [_tableViewRefreshControl performSelector:@selector(endRefreshing) withObject:self afterDelay:3.0];
}

-(void)refreshFriends
{
    [_collectionViewRefreshControl performSelector:@selector(endRefreshing) withObject:self afterDelay:3.0];
}

-(void)configureMainScreen
{
    _mainOverlay = [[UIView alloc]initWithFrame:self.view.frame];
    _mainOverlay.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    [self.view addSubview:_mainOverlay];
    _mainOverlay.userInteractionEnabled = YES;
    
    _dareLabel = [[UILabel alloc]init];
    [self.view addSubview:_dareLabel];
    _dareLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:42]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:130]];
    
    
    _dareLabel.text = @"DARE";
    _dareLabel.textAlignment = NSTextAlignmentCenter;
    _dareLabel.backgroundColor = [UIColor DareBlue];
    _dareLabel.font = [UIFont boldSystemFontOfSize:40];
    _dareLabel.textColor = [UIColor whiteColor];
    
    
    _centerLine = [[UIView alloc]init];
    _centerLine.translatesAutoresizingMaskIntoConstraints = NO;
    _centerLine .backgroundColor = [UIColor DareBlue];
    [self.view addSubview:_centerLine];
    [self.view bringSubviewToFront:_dareLabel];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_centerLine attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_centerLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_centerLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_centerLine attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:10]];
    
    
    
    _dareLabelRightArrows = [[UILabel alloc]init];
    _dareLabelRightArrows.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_dareLabelRightArrows];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabelRightArrows attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_dareLabel attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabelRightArrows attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabelRightArrows attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_dareLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:-5]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabelRightArrows attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_dareLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
    
    
    _dareLabelRightArrows.backgroundColor = [UIColor clearColor];
    FAKFontAwesome *rightLabel = [FAKFontAwesome forwardIconWithSize:48];
    NSMutableAttributedString *rightMutString = [[NSMutableAttributedString alloc]init];
    [rightMutString appendAttributedString:[rightLabel attributedString]];
    [rightMutString appendAttributedString:[rightLabel attributedString]];
    
    _dareLabelRightArrows.textColor = [UIColor DareBlue];
    [_dareLabelRightArrows setAttributedText:rightMutString];
    _dareLabelRightArrows.textAlignment = NSTextAlignmentLeft;
    
    _dareLabelLeftArrows = [[UILabel alloc]init];
    _dareLabelLeftArrows.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_dareLabelLeftArrows];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabelLeftArrows attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabelLeftArrows attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_dareLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:1]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabelLeftArrows attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_dareLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:-5]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_dareLabelLeftArrows attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_dareLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
    
    _dareLabelLeftArrows.backgroundColor = [UIColor clearColor];
    FAKFontAwesome *leftLabel = [FAKFontAwesome backwardIconWithSize:48];
    NSMutableAttributedString *leftMutString = [[NSMutableAttributedString alloc]init];
    [leftMutString appendAttributedString:[leftLabel attributedString]];
    [leftMutString appendAttributedString:[leftLabel attributedString]];
    
    _dareLabelLeftArrows.textColor = [UIColor DareBlue];
    [_dareLabelLeftArrows setAttributedText:leftMutString];
    _dareLabelLeftArrows.textAlignment = NSTextAlignmentRight;
    
    _settingsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
    FAKFontAwesome *settingsIcon = [FAKFontAwesome gearIconWithSize:100];
    [_settingsButton setImage:[settingsIcon imageWithSize:CGSizeMake(100, 100)] forState:UIControlStateNormal];
    [_settingsButton setTintColor:[UIColor DareUnreadBadge]];
    [self.view addSubview:_settingsButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_settingsButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-50.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_settingsButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:40.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_settingsButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:100]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_settingsButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:100]];
    
    _overlayUnreadBadge = [[UILabel alloc]init];
    _overlayUnreadBadge.translatesAutoresizingMaskIntoConstraints = NO;
    _overlayUnreadBadge.textColor = [UIColor DareUnreadBadge];
    _overlayUnreadBadge.font = [UIFont boldSystemFontOfSize:130];
    _overlayUnreadBadge.textAlignment = NSTextAlignmentRight;
    _overlayUnreadBadge.text = [NSString stringWithFormat:@"%d", [self countTotalUnread]];
    [self.view addSubview:_overlayUnreadBadge];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_overlayUnreadBadge attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_overlayUnreadBadge attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_overlayUnreadBadge attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:150]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_overlayUnreadBadge attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    
    UISwipeGestureRecognizer *leftSwipeOnMainView = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(scrollToMessages)];
    leftSwipeOnMainView.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeOnMainView.numberOfTouchesRequired = 1;
    leftSwipeOnMainView.delegate = self;
    [_mainOverlay addGestureRecognizer:leftSwipeOnMainView];
    
    UISwipeGestureRecognizer *rightSwipeOnMainView = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(scrollToFriends)];
    rightSwipeOnMainView.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeOnMainView.numberOfTouchesRequired = 1;
    rightSwipeOnMainView.delegate = self;
    [_mainOverlay addGestureRecognizer:rightSwipeOnMainView];
    
    [self scrollToMainScreen];
    [self showMainPage];
    
}

-(void)showMainPage
{
    _mainOverlay.hidden = NO;
    _dareLabel.hidden = NO;
    _centerLine.hidden = NO;
    _dareLabelLeftArrows.hidden = NO;
    _dareLabelRightArrows.hidden = NO;
    _settingsButton.hidden = NO;
    _overlayUnreadBadge.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        _mainOverlay.alpha = 0.8;
        [_mainOverlay bringSubviewToFront:_dareLabel];
        _dareLabel.alpha = 1.0;
        _centerLine.alpha = 1.0;
        _dareLabelRightArrows.alpha = 1.0;
        _dareLabelLeftArrows.alpha = 1.0;
        _settingsButton.alpha = 1.0;
        _overlayUnreadBadge.alpha = 1.0;
        _friendsCornerButton.alpha = 0;
    }completion:^(BOOL finished) {
        _friendsCornerButton.hidden = YES;
    }];
    
}

-(void)hideMainPage
{
    _friendsCornerButton.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _mainOverlay.alpha = 0;
        _dareLabel.alpha = 0;
        _centerLine.alpha = 0;
        _dareLabelRightArrows.alpha = 0;
        _dareLabelLeftArrows.alpha = 0;
        _settingsButton.alpha = 0;
        _overlayUnreadBadge.alpha = 0;
        _friendsCornerButton.alpha = 1;
    } completion:^(BOOL finished) {
        _mainOverlay.hidden = YES;
        _dareLabel.hidden = YES;
        _centerLine.hidden = YES;
        _dareLabelRightArrows.hidden = YES;
        _dareLabelLeftArrows.hidden = YES;
        _settingsButton.hidden = YES;
        _overlayUnreadBadge.hidden = YES;
        
    }];
    
}
-(void)scrollToFriends
{
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self hideMainPage];
}

-(void)scrollToMessages
{
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentSize.width - _tableView.frame.size.width, 0) animated:YES];
    [self hideMainPage];
    _friendsCornerButton.hidden = YES;
}

-(void)scrollToMainScreen
{
    [_scrollView setContentOffset:CGPointMake(_collectionView.frame.size.width/2, 0) animated:YES];
    [self showMainPage];
}

-(void)settingsButtonPressed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UINavigationController *settingsNavController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsNavController"];
    [self presentViewController:settingsNavController animated:YES completion:nil];
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
    return [self.friends count] + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.friends count]) {
        FinalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FinalCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.cellLabel.text = @"";
        cell.userInteractionEnabled = NO;
        return cell;
    } else {
        FriendListIcon *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
        if ([_selectedIndices containsObject:@(indexPath.row)]) {
            cell.selectedOverlay.backgroundColor = [UIColor DareOverlaySeletcedCell];
        } else {
            cell.selectedOverlay.backgroundColor = [UIColor clearColor];
        }
        Friend *friend = self.friends[indexPath.row];
        UIImage *friendImage = [UIImage imageWithData:friend.image];
        ((FriendListIcon*)cell).friendImage.image = friendImage;
        return cell;
    }
    return nil;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(_collectionViewFriendWidth, _collectionViewFriendHeight);
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //    [UIView animateWithDuration:0.5 animations:^{
    //        _friendsCornerButton.alpha = 1.0;
    //    }];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //    if (!decelerate) {
    //        [UIView animateWithDuration:0.5 animations:^{
    //            _friendsCornerButton.alpha = 1.0;
    //        }];
    //    }
}



-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //    [UIView animateWithDuration:0.5 animations:^{
    //        _friendsCornerButton.alpha = 0;
    //    }];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (![_selectedIndices containsObject:@(indexPath.row)]) {
        [_selectedIndices addObject:@(indexPath.row)];
    }else{
        [_selectedIndices removeObject:@(indexPath.row)];
    }
    
    if ([_selectedIndices count]>0) {
        _isArrow = YES;
        _friendsCornerButton.titleLabel.text = @"➡︎";
    }else{
        _friendsCornerButton.titleLabel.text = @"＋";
        _isArrow = NO;
    }
    [collectionView reloadData];
    
    for (NSNumber *index in _selectedIndices) {
        if ([index integerValue] < [self.friends count]) {
            [self.selectedFriends addObject:[self.friends objectAtIndex:[index integerValue]]];
        }
    }
    
    NSLog(@"%@", _selectedIndices);
    [collectionView reloadData];
    
}

-(void)friendsCornerButtonPressed
{
    if (_isArrow) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        NewDareViewController *viewController = (NewDareViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NewDare"];
        viewController.friends = [[self.selectedFriends allObjects]mutableCopy];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.threads count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 112.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DareCell" forIndexPath:indexPath];

    MessageThread *thread = self.threads[indexPath.row];
    UIImage *background = [UIImage imageWithData:thread.backgroundPicture];
    ((DareCell *)cell).backgroundImageView.image = background;
    ((DareCell *)cell).titleLabel.text = [NSString stringWithFormat:@"I DARE YOU TO\n%@", thread.title];
    NSInteger unreadCount = 0;
    for (Message *message in thread.messages) {
        if ([message.isRead integerValue] == 0) {
                unreadCount++;
        }
    }
    ((DareCell *)cell).unreadCountLabel.text = [NSString stringWithFormat:@"%d", unreadCount];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageThread *thread = self.threads[indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    MessagesTVC *viewController = (MessagesTVC *)[storyboard instantiateViewControllerWithIdentifier:@"MessagesTVC"];
    viewController.thread = thread;
    viewController.friends = [NSMutableArray arrayWithArray:self.friends];
    [self.navigationController pushViewController:viewController animated:YES];
}






@end
