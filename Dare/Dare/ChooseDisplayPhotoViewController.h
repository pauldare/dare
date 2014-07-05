//
//  ChooseDisplayPhotoViewController.h
//  Dare
//
//  Created by Test on 6/29/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseDisplayPhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) BOOL captureSessionIsActive;
@property (nonatomic) BOOL fromSettings;

@end
