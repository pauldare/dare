//
//  MessagesTVC.m
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "MessagesTVC.h"
#import "HeaderCell.h"
#import "UIColor+DareColors.h"
#import "MessageCell.h"
#import "AddCommentCell.h"
#import "Message+Methods.h"
#import "MessageThread+Methods.h"
#import "SnapCommentVC.h"
#import "DareDataStore.h"
#import "MainScreenViewController.h"

@interface MessagesTVC ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UINib *headerCell;
@property (strong, nonatomic) UINib *messageCell;
@property (strong, nonatomic) UINib *addCommentCell;

@property (strong, nonatomic) Message *headerMessage;
@property (strong, nonatomic) DareDataStore *dataStore;

@end

@implementation MessagesTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messages = [NSMutableArray arrayWithArray:[self.thread.messages allObjects]];
    NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    [self.messages sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
    self.headerMessage = self.messages[0];
    [self.messages removeObjectAtIndex:0];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor DareBlue];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.headerCell = [UINib nibWithNibName:@"HeaderCell" bundle:nil];
    [self.tableView registerNib:self.headerCell forCellReuseIdentifier:@"HeaderCell"];
    self.messageCell = [UINib nibWithNibName:@"MessageCell" bundle:nil];
    [self.tableView registerNib:self.messageCell forCellReuseIdentifier:@"MessageCell"];
    self.addCommentCell = [UINib nibWithNibName:@"AddCommentCell" bundle:nil];
    [self.tableView registerNib:self.addCommentCell forCellReuseIdentifier:@"AddCommentCell"];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.canCancelContentTouches = NO;
    self.tableView.exclusiveTouch = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc]initWithFrame:CGRectZero];
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (CGFloat)getRowHeightForCell: (NSString *)identifier
{
    return [[[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil] objectAtIndex:0] bounds].size.height;
}

- (void)markAllMessagesAsRead
{
    for (Message *message in self.messages) {
        message.isRead = @1;
        [self.dataStore saveContext];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ 
    switch (section) {
        case 1:
            return [self.messages count];
            break;
        default:
            return 1;
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return [self getRowHeightForCell:@"HeaderCell"];
            break;
        case 1:
            return [self getRowHeightForCell:@"MessageCell"];
            break; 
        default:
            return [self getRowHeightForCell:@"AddCommentCell"];
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {        
        NSString *cellIdentifier = @"HeaderCell";
        HeaderCell *cell = (HeaderCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.mainImage.image = [UIImage imageWithData: self.headerMessage.picture];
        cell.backgroundImage.image = [UIImage imageWithData: self.thread.backgroundPicture];
        cell.mainImage.contentMode = UIViewContentModeScaleToFill;
        cell.textLabel.text = self.thread.title;
        cell.textLabel.backgroundColor = [UIColor DareCellOverlay];
        cell.userImage.image = [UIImage imageWithData:self.thread.author];
        //cell.friends = self.friends;
              cell.collectionView.alwaysBounceHorizontal = YES;
        cell.collectionView.userInteractionEnabled = YES;
        cell.collectionView.scrollEnabled = YES;
        cell.collectionView.canCancelContentTouches = NO;
        cell.collectionView.delaysContentTouches = YES;
        UISwipeGestureRecognizer *leftSwipeOnScrollView = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftOnCollectionView:)];
        leftSwipeOnScrollView.direction = UISwipeGestureRecognizerDirectionLeft;
        leftSwipeOnScrollView.delegate = self;
        [cell addGestureRecognizer:leftSwipeOnScrollView];
        
        UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightOnCollectionView:)];
        rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        rightSwipeGesture.delegate = self;
        [cell addGestureRecognizer:rightSwipeGesture];
        
        return cell;
        
    } else if (indexPath.section == 1){
        Message *message = self.messages[indexPath.row];
        NSString *cellIdentifier = @"MessageCell";
        MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = message.text;
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        cell.imageView.image = [UIImage imageWithData:message.picture];
        cell.userPic.image = [UIImage imageWithData:message.author];
        cell.centeredUserPic.image = [UIImage imageWithData:message.author];
        
        UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightOnCollectionView:)];
        rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        rightSwipeGesture.delegate = self;
        [cell addGestureRecognizer:rightSwipeGesture];
        
        return cell;
        
    } else {
        NSString *cellIdentifier = @"AddCommentCell";
        AddCommentCell *cell = (AddCommentCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[AddCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        return cell;
    }
    return nil;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
-(void)swipeLeftOnCollectionView:(UIGestureRecognizer *)sender
{
    self.tableView.scrollEnabled = NO;
    NSLog(@"%@", [sender.view class]);
    if ([sender.view isKindOfClass:[HeaderCell class]]) {
        HeaderCell *headerCell = (HeaderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        if ([sender locationInView:sender.view].y < headerCell.collectionView.frame.size.height + 50) {
            if (headerCell.collectionView.contentOffset.x < headerCell.collectionView.contentSize.width - headerCell.collectionView.frame.size.width) {
            [headerCell.collectionView setContentOffset:CGPointMake(headerCell.collectionView.contentOffset.x + headerCell.collectionView.frame.size.width, 0)animated:YES];
            }
        }
    }
    NSLog(@"%f %f",[sender locationInView:sender.view].x, [sender locationInView:sender.view].y);
    
    self.tableView.scrollEnabled = YES;
}

-(void)swipeRightOnCollectionView:(UIGestureRecognizer *)sender
{
    if ([sender.view isKindOfClass:[HeaderCell class]]) {
        HeaderCell *headerCell = (HeaderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        if ([sender locationInView:sender.view].y < headerCell.collectionView.frame.size.height + 50) {
            if (headerCell.collectionView.contentOffset.x - headerCell.collectionView.frame.size.width > 0) {
                [headerCell.collectionView setContentOffset:CGPointMake(headerCell.collectionView.contentOffset.x - headerCell.collectionView.frame.size.width, 0)animated:YES];
            }else{
                [headerCell.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
        }else{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            UINavigationController *mainViewNavController = [storyBoard instantiateViewControllerWithIdentifier:@"MainNavController"];
            MainScreenViewController *mainScreen = mainViewNavController.viewControllers[0];
            mainScreen.fromCancel = YES;
            mainScreen.fromNew = NO;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
            mainScreen.threads = [[NSMutableArray alloc]initWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
            [self presentViewController:mainViewNavController animated:NO completion:nil];
        }
    }else{
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        UINavigationController *mainViewNavController = [storyBoard instantiateViewControllerWithIdentifier:@"MainNavController"];
        MainScreenViewController *mainScreen = mainViewNavController.viewControllers[0];
        mainScreen.fromCancel = YES;
        mainScreen.fromNew = NO;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
        mainScreen.threads = [[NSMutableArray alloc]initWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
        [self presentViewController:mainViewNavController animated:NO completion:nil];
    }
    self.tableView.scrollEnabled = YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        SnapCommentVC *viewController = (SnapCommentVC *)[storyboard instantiateViewControllerWithIdentifier:@"SnapCommentVC"];
        viewController.thread = self.thread;
        [self presentViewController:viewController animated:YES completion:nil];
    }

}



@end
