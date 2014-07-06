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

@interface MessagesTVC ()

@property (strong, nonatomic) UINib *headerCell;
@property (strong, nonatomic) UINib *messageCell;
@property (strong, nonatomic) UINib *addCommentCell;
@property (strong, nonatomic) NSMutableArray *messages;
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
        cell.friends = self.friends;
        return cell;
    } else if (indexPath.section == 1){
        Message *message = self.messages[indexPath.row];
        NSString *cellIdentifier = @"MessageCell";
        MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = message.text;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.image = [UIImage imageWithData:message.picture];
        cell.userPic.image = [UIImage imageWithData:message.author];
        cell.centeredUserPic.image = [UIImage imageWithData:message.author];
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
