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
#import "TextCommentCell.h"
#import "ParseClient.h"
#import "UnreadCounter.h"
#import "Friend+Methods.h"



@interface MessagesTVC ()<UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UINib *headerCell;
@property (strong, nonatomic) UINib *messageCell;
@property (strong, nonatomic) UINib *addCommentCell;
@property (strong, nonatomic) UINib *textCommentCell;

@property (strong, nonatomic) Message *headerMessage;
@property (strong, nonatomic) DareDataStore *dataStore;
@property (strong, nonatomic) UIView *commentOverlay;
@property (strong, nonatomic) UITextView *commentText;
@property (strong, nonatomic) UITextField *responderText;

@property (strong, nonatomic) UIButton *blurButton;

@property (strong, nonatomic) NSArray *friendsForThread;


@end

@implementation MessagesTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    [UnreadCounter sharedCounter].unreadMessages = 0;
    self.dataStore = [DareDataStore sharedDataStore];
    self.messages = [NSMutableArray arrayWithArray:[self.thread.messages allObjects]];
    
    for (Message *message in self.messages) {
        PFQuery *messageQuery = [PFQuery queryWithClassName:@"Message"];
        [messageQuery whereKey:@"objectId" equalTo:message.identifier];
        [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *parseMessage in objects) {
                [ParseClient storeRelation:[PFUser currentUser] toReadersListForMessage:parseMessage completion:^{
                    
                }];
            }
        }];
    }
    
    self.friendsForThread = [self fetchFriendsToShow];
    
    
    NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    [self.messages sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
    self.headerMessage = self.messages[0];
    [self.messages removeObjectAtIndex:0];
    self.tableView.backgroundColor = [UIColor DareBlue];
    self.view.backgroundColor = [UIColor DareBlue];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.headerCell = [UINib nibWithNibName:@"HeaderCell" bundle:nil];
    [self.tableView registerNib:self.headerCell forCellReuseIdentifier:@"HeaderCell"];
    self.messageCell = [UINib nibWithNibName:@"MessageCell" bundle:nil];
    [self.tableView registerNib:self.messageCell forCellReuseIdentifier:@"MessageCell"];
    self.addCommentCell = [UINib nibWithNibName:@"AddCommentCell" bundle:nil];
    [self.tableView registerNib:self.addCommentCell forCellReuseIdentifier:@"AddCommentCell"];
    self.textCommentCell = [UINib nibWithNibName:@"textCommentCell" bundle:nil];
    [self.tableView registerNib:self.textCommentCell forCellReuseIdentifier:@"TextCommentCell"];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.canCancelContentTouches = NO;
    self.tableView.exclusiveTouch = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(changeFirstResponder:)
                                                      name:UIKeyboardDidShowNotification
                                                    object:nil];
}

- (void)fetchParseThread: (void(^)(PFObject *parseThread))completion
{
    PFQuery *threadQuery = [PFQuery queryWithClassName:@"MessageThread"];
    [threadQuery whereKey:@"objectId" equalTo:self.thread.identifier];
    [threadQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *parseThread = objects[0];
        completion(parseThread);
    }];
}


- (NSArray *)fetchFriendsToShow
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    NSArray *friends = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return friends;
//    [self fetchParseThread:^(PFObject *parseThread) {
//        [ParseClient getFriendsForThread:parseThread completion:^(NSArray *parseFriends) {
//            
//            NSInteger count = 0;
//            __block BOOL isDone = NO;
//
//            for (PFUser *friend in parseFriends) {
//                count++;
//                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
//                NSString *searchID = friend[@"fbId"];
//                NSLog(@"facebook id: %@", friend[@"fbId"]);
//                NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"identifier==%@",searchID];
//                fetchRequest.predicate = searchPredicate;
//                NSArray *friends = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil];
//                if ([friends count] != 0) {
//                    Friend *newFriend = friends[0];
//                    NSLog(@"newFriend: %@", newFriend.displayName);
//                    [self.thread addFriendsObject:newFriend];
//                }
//                
//                if (count == [parseFriends count]) {
//                    isDone = YES;
//                }
//            }
//        }];
//    }];
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
    return [[[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil] objectAtIndex:0] frame].size.height;
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
    
    if (indexPath.section == 0) {
        return [self getRowHeightForCell:@"HeaderCell"];
        
    }else if (indexPath.section == 1){
        if ( ((Message*)self.messages[indexPath.row]).picture) {
            return [self getRowHeightForCell:@"MessageCell"];
        }else{
            return [self getRowHeightForCell:@"textCommentCell"];
        }
        
    }else{
        return [self getRowHeightForCell:@"AddCommentCell"];
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
        
        
        cell.friends = [self.friendsForThread mutableCopy];
        
        //cell.friends = [self fetchFriendsToShow];
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
       
        if (message.picture) {
            NSString *cellIdentifier = @"MessageCell";
            MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.textLabel.text = message.text;
            cell.imageView.contentMode = UIViewContentModeScaleToFill;
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [cell addGestureRecognizer:tapGestureRecognizer];

            if ([message.blurTimer integerValue] != 0 && [message.isViewed integerValue] == 0) {
                
                dispatch_queue_t queue = dispatch_queue_create("queue", 0);
                dispatch_async(queue, ^{
                    UIImage *blurredImage = [UIColor blurryImage:[UIImage imageWithData:message.picture] withBlurLevel:0.6f];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell.spinner stopAnimating];
                        cell.imageView.image = blurredImage;
                    });
                });
                
                tapGestureRecognizer.enabled = YES;
                                             
            }else if ([message.isViewed integerValue] != 0){
                cell.imageView.image = [UIColor blurryImage:[UIImage imageWithData:message.picture] withBlurLevel:0.6f];
                tapGestureRecognizer.enabled = NO;
                
            }else {
                cell.imageView.image = [UIImage imageWithData:message.picture];
                tapGestureRecognizer.enabled = NO;
            }
            cell.centeredUserPic.image = [UIImage imageWithData:message.author];

            UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightOnCollectionView:)];
            rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
            rightSwipeGesture.delegate = self;
            [cell addGestureRecognizer:rightSwipeGesture];
            cell.userInteractionEnabled = YES;
            return cell;
        }else{
            
            NSString *cellIdentifier = @"TextCommentCell";
            TextCommentCell *cell = (TextCommentCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[TextCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            cell.commentLabel.text =  message.text;
            cell.userImage.image = [UIImage imageWithData:message.author];
            cell.contentView.backgroundColor = [UIColor DarePurpleComment];
            
            UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightOnCollectionView:)];
            rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
            rightSwipeGesture.delegate = self;
            [cell addGestureRecognizer:rightSwipeGesture];
            return cell;
        }
    } else {
        NSString *cellIdentifier = @"AddCommentCell";
        AddCommentCell *cell = (AddCommentCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[AddCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        UIButton *dareButton = ((AddCommentCell*)cell).iDareButton;
        cell.userInteractionEnabled = YES;
        [dareButton addTarget:self action:@selector(iDarePressed) forControlEvents:UIControlEventTouchUpInside];
        UIButton *commentButton =((AddCommentCell*)cell).commentButton;
        [commentButton addTarget:self action:@selector(commentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        cell.backgroundColor = [UIColor DareBlue];
        cell.contentView.backgroundColor = [UIColor DareBlue];
        return cell;
    }
    return nil;
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"%@",tapGestureRecognizer.view);
    MessageCell *messageCell = (MessageCell*)tapGestureRecognizer.view;
//<<<<<<< HEAD
//    NSLog(@"%ld",(long)[self.tableView indexPathForCell:messageCell].row);
//    NSInteger blurTimer = [((Message*)self.messages[[self.tableView indexPathForCell:messageCell].row]).blurTimer integerValue];
//    [self performSelector:@selector(viewBlurredImagewithCell:) withObject:messageCell afterDelay:blurTimer];
//    ((Message*)self.messages[[self.tableView indexPathForCell:messageCell].row]).blurTimer = 0;
//    [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:messageCell]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    
//=======
    NSLog(@"%ld",(long)[self.tableView indexPathForCell:messageCell].row);
    if (!((Message*)self.messages[[self.tableView indexPathForCell:messageCell].row]).isViewed) {
        NSInteger blurTimer = [((Message*)self.messages[[self.tableView indexPathForCell:messageCell].row]).blurTimer integerValue];
        [self performSelector:@selector(viewBlurredImagewithCell:) withObject:messageCell afterDelay:blurTimer];
        ((Message*)self.messages[[self.tableView indexPathForCell:messageCell].row]).blurTimer = 0;
        [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:messageCell]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}

-(void)viewBlurredImagewithCell:(MessageCell*)cell
{
    Message *cellMessage = self.messages[[self.tableView indexPathForRowAtPoint:cell.center].row];
    
    [ParseClient fetchMessage:cellMessage completion:^(PFObject *parseMessage) {
        [ParseClient storeRelation:[PFUser currentUser] toViewersListOfMessage:parseMessage completion:^{
        }];
    }];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    NSString *searchID = cellMessage.identifier;
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"identifier==%@",searchID];
    fetchRequest.predicate = searchPredicate;
    NSArray *messages = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    Message *coreDataMessage = messages[0];
    coreDataMessage.isViewed = @1;
    [self.dataStore saveContext];
    
    NSFetchRequest *fetchThread = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
    NSString *threadID = self.thread.identifier;
    NSPredicate *searchThread = [NSPredicate predicateWithFormat:@"identifier==%@",threadID];
    fetchThread.predicate = searchThread;
    NSArray *threads = [self.dataStore.managedObjectContext executeFetchRequest:fetchThread error:nil];
    MessageThread *thread = threads[0];
    self.messages = [NSMutableArray arrayWithArray:[thread.messages allObjects]];
    NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    [self.messages sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
    self.headerMessage = self.messages[0];
    [self.messages removeObjectAtIndex:0];
    
    [self.tableView reloadData];
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

-(void)iDarePressed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    SnapCommentVC *viewController = (SnapCommentVC *)[storyboard instantiateViewControllerWithIdentifier:@"SnapCommentVC"];
    viewController.thread = self.thread;
    [self presentViewController:viewController animated:YES completion:nil];
    self.tableView.scrollEnabled = YES;
}

-(void)commentButtonPressed
{
    _responderText = [[UITextField alloc]init];
    _responderText.hidden = YES;
    [self setupCommentOverlay];
    [self.view.window addSubview:_responderText];
    // [self.view bringSubviewToFront:_commentOverlay];
    //[self moveOverlayIntoView];
    _responderText.userInteractionEnabled = YES;
    _responderText.inputAccessoryView = _commentOverlay;
    [_responderText becomeFirstResponder];
    
    _commentText.frame = _commentOverlay.frame;
    
    [self.view.window layoutIfNeeded];
    
    NSInteger commentCells = [self.tableView numberOfRowsInSection:1];
    if (commentCells > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(commentCells -1) inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

-(void)changeFirstResponder:(id)sender
{
    _commentText = [[UITextView alloc]init];
    _commentText.userInteractionEnabled = YES;
    _commentText.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_commentOverlay addSubview:_commentText];
    
    [_commentOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_commentText attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_commentOverlay attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [_commentOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_commentText attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_commentOverlay attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [_commentOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_commentText attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_commentOverlay attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [_commentOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_commentText attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_commentOverlay attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [_commentOverlay bringSubviewToFront:_commentText];
    _commentText.returnKeyType = UIReturnKeySend;
    _commentText.delegate = self;
    _commentText.textAlignment = NSTextAlignmentCenter;
    _commentText.backgroundColor = [UIColor clearColor];
    _commentText.font = [UIFont boldSystemFontOfSize:25];
    _commentText.textColor = [UIColor whiteColor];
    
    [_commentText addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    [_commentText becomeFirstResponder];
    [_responderText resignFirstResponder];
    
    [self.view layoutIfNeeded];
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSUInteger maxNumberOfLines = 2;
    NSUInteger numLines = textView.contentSize.height/textView.font.lineHeight;
    
    if (numLines > maxNumberOfLines)
    {
        textView.text = [textView.text substringToIndex:textView.text.length - 1];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_responderText resignFirstResponder];
    [_commentText resignFirstResponder];
    [self.view endEditing:YES];
    [self.view.window endEditing:YES];
    [_commentOverlay endEditing:YES];
    [_commentText.superview endEditing:YES];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    __typeof__(self) __block wself = self;
    [self addMessageToThread:^(Message *message, MessageThread *messageThread) {
        wself.messages = [[messageThread.messages allObjects]mutableCopy];
        NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
        [wself.messages sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
        wself.headerMessage = wself.messages[0];
        [wself.messages removeObjectAtIndex:0];
        [wself.tableView reloadData];
    }];

    [_responderText resignFirstResponder];
    [_commentText resignFirstResponder];
    [self.view endEditing:YES];
    [self.view.window endEditing:YES];
    [_commentOverlay endEditing:YES];
    [_commentText.superview endEditing:YES];
    
    
#warning create post here with _commentText.text
    
    return NO;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    
}

-(void)setupCommentOverlay
{
    _commentOverlay = [[UIView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 112)];
    _commentOverlay.backgroundColor = [UIColor DarePurpleComment];
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDownOnComment)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    downSwipe.numberOfTouchesRequired = 1;
    [_commentOverlay addGestureRecognizer:downSwipe];
    
}

-(void)swipeDownOnComment
{
    
    [_responderText resignFirstResponder];
    [_commentText resignFirstResponder];
    [self.view endEditing:YES];
    [self.view.window endEditing:YES];
    [_commentOverlay endEditing:YES];
    [_commentText.superview endEditing:YES];
    
}

- (void)addMessageToThread: (void(^)(Message *, MessageThread *))completion
{
    [ParseClient addMessageToThread:self.thread withText:_commentText.text
                            picture:nil
                          blurTimer:0
                         completion:^(PFObject *message) {
                             Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
                                                                                 inManagedObjectContext:self.dataStore.managedObjectContext];
                             newMessage.identifier = message.objectId;
                             newMessage.text = message[@"text"];
                             PFFile *messageImageFile = message[@"picture"];
                             [messageImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                 newMessage.picture = data;
                             }];
                             PFFile *messageAuthorImage = message[@"author"];
                             [messageAuthorImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                 newMessage.author = data;
                             }];
                             newMessage.createdAt = message.createdAt;
                             newMessage.isRead = @1;
                             [self.thread addMessagesObject:newMessage];
                             
                             [self.dataStore saveContext];
                             
                             NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
                             NSString *searchID = self.thread.identifier;
                             NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"identifier==%@",searchID];
                             fetchRequest.predicate = searchPredicate;
                             NSArray *threads = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil];
                             MessageThread *thread = threads[0];
                             completion(newMessage, thread);
                         }];
}


@end
