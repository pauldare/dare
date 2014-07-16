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
#import "SettingsViewController.h"


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
@property (strong, nonatomic) UIImage *chosenImage;

// For use in the storyboards.

@end

@implementation ChooseDisplayPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataStore = [DareDataStore sharedDataStore];

    self.overlayView.backgroundColor = [UIColor clearColor];
    
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
    
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGesture];
}

-(void)swipeRight:(UIGestureRecognizer *)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    SettingsViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"SettingsVC"];
    [self presentViewController:vc animated:YES completion:nil];
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
                                            
                                            UIImage *displayImage = [self fixOrientationforImage:newImage];
                                            [self changeImageOnParse:displayImage completion:^{
                                                NSData *imageData = UIImagePNGRepresentation(displayImage);
                                                self.coreDataUser.profileImage = imageData;
                                                [self.dataStore saveContext];
                                            }];                                            
    } failure:^{
            [self selectPictureFromLibrary];
    }];
}

- (UIImage *)fixOrientationforImage:(UIImage*)image {
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
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
    self.chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = self.chosenImage;
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        [self changeImageOnParse:self.chosenImage completion:^{
            NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 0.5f);
            self.coreDataUser.profileImage = imageData;
            [self.dataStore saveContext];
        }];
    });
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (UIImage *)resizeImage: (UIImage *)image
{
    CGSize destinationSize = CGSizeMake(100, 100);
    UIGraphicsBeginImageContext(destinationSize);
    [image drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)changeImageOnParse: (UIImage *)newImage
                completion: (void(^)())completion
{
    //UIImage *resizedImage = [self resizeImage:newImage];
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.5f);
    PFFile *file = [PFFile fileWithData:imageData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.loggedUser setObject:file forKey:@"image"];
        [self.loggedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            completion();
        }];
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
        SettingsViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"SettingsVC"];
        vc.userPic = self.chosenImage;
        [self presentViewController:vc animated:YES completion:nil];
    }
}


@end
