//
//  Friend.h
//  Dare
//
//  Created by Nadia on 7/4/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) User *user;

@end
