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


@interface MessagesTVC ()

@property (strong, nonatomic) UINib *headerCell;
@property (strong, nonatomic) UINib *messageCell;
@property (strong, nonatomic) UINib *addCommentCell;

@end

@implementation MessagesTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor DareBlue];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.headerCell = [UINib nibWithNibName:@"HeaderCell" bundle:nil];
    [self.tableView registerNib:self.headerCell forCellReuseIdentifier:@"HeaderCell"];
    self.messageCell = [UINib nibWithNibName:@"MessageCell" bundle:nil];
    [self.tableView registerNib:self.messageCell forCellReuseIdentifier:@"MessageCell"];
    self.addCommentCell = [UINib nibWithNibName:@"AddCommentCell" bundle:nil];
    [self.tableView registerNib:self.addCommentCell forCellReuseIdentifier:@"AddCommentCell"];
}

- (CGFloat)getRowHeightForCell: (NSString *)identifier
{
    return [[[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil] objectAtIndex:0] bounds].size.height;
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
            return 2;
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
        return cell;
    } else if (indexPath.section == 1){        
        NSString *cellIdentifier = @"MessageCell";
        MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
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






@end
