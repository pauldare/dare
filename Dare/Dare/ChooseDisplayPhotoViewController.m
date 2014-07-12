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
#import "DareDataStore.h"
#import "User+Methods.h"
#import "MainScreenViewController.h"


@interface ChooseDisplayPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic) BOOL frontCamera;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *cameraCaptureButton;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;
@property (strong, nonatomic) PFUser *loggedUser;
@property (strong, nonatomic) CameraManager *cameraManager;
@property (strong, nonatomic) DareDataStore *dataStore;
@property (strong, nonatomic) User *coreDataUser;

// For use in the storyboards.

@end

@implementation ChooseDisplayPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataStore = [DareDataStore sharedDataStore];
    [self fetchLoggedUser:^{
        UIImage *image = [UIImage imageWithData:self.coreDataUser.profileImage];
        self.imageView.image = image;
    }];
    self.loggedUser = [PFUser currentUser];
    self.cameraManager = [[CameraManager alloc]init];
    if (self.fromSettings) {
        self.nextLabel.text = @"DONE";
    }

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
}

- (void)fetchLoggedUser: (void(^)())completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    self.coreDataUser = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil][0];
    completion();
}


- (IBAction)snapStillImage:(id)sender
{
    [self.cameraManager snapStillImageForImageView:self.imageView
                                           isFront:YES
                                              view:self.cameraView
                                        completion:^(UIImage *newImage) {
                                            [self changeImageOnParse:newImage completion:^{
                                                NSData *imageData = UIImagePNGRepresentation(newImage);
                                                self.coreDataUser.profileImage = imageData;
                                                [self.dataStore saveContext];
                                            }];                                            
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [self changeImageOnParse:chosenImage completion:^{
        NSData *imageData = UIImagePNGRepresentation(chosenImage);
        self.coreDataUser.profileImage = imageData;
        [self.dataStore saveContext];
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (void)changeImageOnParse: (UIImage *)newImage
                completion: (void(^)())completion
{
    NSData *imageData = UIImagePNGRepresentation(newImage);
    PFFile *file = [PFFile fileWithData:imageData];
    [file saveInBackground];
    [self.loggedUser setObject:file forKey:@"image"];
    [self.loggedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completion();
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)presentNextView
{
    if (!self.fromSettings) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        UINavigationController *mainScreenNavController = [storyBoard instantiateViewControllerWithIdentifier:@"MainNavController"];
        MainScreenViewController *mainScreen = mainScreenNavController.viewControllers[0];
        mainScreen.fromCancel = NO;
        mainScreen.fromNew = YES;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
        mainScreen.threads = [[NSMutableArray alloc]initWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
        [self presentViewController:mainScreenNavController animated:YES completion:nil];
    } else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"SettingsVC"];
        [self presentViewController:vc animated:YES completion:nil];
    }
}



@end
