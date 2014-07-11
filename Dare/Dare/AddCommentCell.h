//
//  AddCommentCell.h
//  Dare
//
//  Created by Nadia on 7/5/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *iDareButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
- (IBAction)iDareButtonPressed:(id)sender;
- (IBAction)commentButtonPressed:(id)sender;


@end
