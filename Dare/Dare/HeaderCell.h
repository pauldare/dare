//
//  HeaderCell.h
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DareDataStore.h"

@interface HeaderCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) DareDataStore *dataStore;
@property (strong, nonatomic) NSArray *friends;

@end
