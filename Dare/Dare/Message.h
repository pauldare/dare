//
//  Message.h
//  Dare
//
//  Created by Carlos Meirin on 6/28/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Message : NSObject

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *poster;
@property (strong, nonatomic) NSString *thread;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIImage *picture;
@property (nonatomic) BOOL shouldBlur;
@property (nonatomic) NSInteger blurTimer;
@property (nonatomic) BOOL hasBeenViewed;
@property (strong, nonatomic) PFObject *parseObject;

+(Message*)createNewMessage;

-(void)postMessageToPost;

@end
