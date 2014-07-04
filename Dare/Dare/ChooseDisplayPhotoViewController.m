//
//  ChooseDisplayPhotoViewController.m
//  Dare
//
//  Created by Test on 6/29/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "ChooseDisplayPhotoViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CameraManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIColor+DareColors.h"
#import "ParseClient.h"


@interface ChooseDisplayPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic) BOOL frontCamera;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *cameraCaptureButton;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;
@property (strong, nonatomic) PFUser *loggedUser;
@property (strong, nonatomic) CameraManager *cameraManager;

// For use in the storyboards.

@end

@implementation ChooseDisplayPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loggedUser = [PFUser currentUser];
    
    self.cameraManager = [[CameraManager alloc]init];

    _cameraCaptureButton.tintColor = [UIColor DareBlue];
    _imageView.backgroundColor = [UIColor DareBlue];
    _cameraView.backgroundColor = [UIColor DareBlue];
    [self.view bringSubviewToFront:_cameraCaptureButton];

    UITapGestureRecognizer *arrowTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(presentNextView)];
    arrowTapGesture.numberOfTapsRequired =1;
    [_arrowLabel addGestureRecognizer:arrowTapGesture];
    
    UITapGestureRecognizer *nextTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(presentNextView)];
    nextTapGesture.numberOfTapsRequired =1;
    [_nextLabel addGestureRecognizer:arrowTapGesture];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(presentNextView)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];

//    
//    [ParseClient getUser:self.loggedUser completion:^(User *loggedUser) {
//        _imageView.image = loggedUser.profileImage;
//    } failure:nil];
}



- (IBAction)snapStillImage:(id)sender
{
    [self.cameraManager snapStillImageForImageView:self.imageView
                                           isFront:YES
                                              view:self.cameraView
                                        completion:^(UIImage *newImage) {
        [self changeImageOnParse:newImage];
    } failure:^{
        [self selectPictureFromLibrary];
    }];
}

- (void)selectPictureFromLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [self changeImageOnParse:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)changeImageOnParse: (UIImage *)newImage
{
    NSData *imageData = UIImagePNGRepresentation(newImage);
    PFFile *file = [PFFile fileWithName:@"image" data:imageData];
    [file saveInBackground];
    [self.loggedUser setObject:file forKey:@"image"];
    [self.loggedUser saveInBackground];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)presentNextView
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"DareTable"];
    [self presentViewController:vc animated:YES completion:nil];
}



@end
