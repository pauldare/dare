//
//  MessagesTVC.h
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message+Methods.h"
#import "MessageThread+Methods.h"


@interface MessagesTVC : UITableViewController

@property (strong, nonatomic) MessageThread *thread;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSDictionary *blurredImages;

@end
