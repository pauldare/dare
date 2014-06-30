//
//  ChooseDisplayPhotoViewController.m
//  Dare
//
//  Created by Test on 6/29/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "ChooseDisplayPhotoViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIColor+DareColors.h"
#import "ParseClient.h"


@interface ChooseDisplayPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) BOOL frontCamera;
@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *capturedImage;
@property (nonatomic) BOOL captureSessionIsActive;
@property (weak, nonatomic) IBOutlet UIButton *cameraCaptureButton;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;
@property (strong, nonatomic) PFUser *loggedUser;

// For use in the storyboards.

@end

@implementation ChooseDisplayPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loggedUser = [PFUser currentUser];
    _captureSessionIsActive = NO;
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

    
    [ParseClient getUser:self.loggedUser completion:^(User *loggedUser) {
        _imageView.image = loggedUser.profileImage;
    } failure:nil];
}


- (void) initializeCamera {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        _imageView.hidden = YES;
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        captureVideoPreviewLayer.frame = self.cameraView.bounds;
        [self.cameraView.layer addSublayer:captureVideoPreviewLayer];
        
        NSArray *devices = [AVCaptureDevice devices];
        AVCaptureDevice *frontCamera;
        
        for (AVCaptureDevice *device in devices) {
            
            if ([device hasMediaType:AVMediaTypeVideo]) {
                
                if ([device position] == AVCaptureDevicePositionFront) {
                    
                    frontCamera = device;
                }
            }
        }
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        
        [_session addInput:input];
        
        
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        
        [_session addOutput:self.stillImageOutput];
        
        [_session startRunning];
        _captureSessionIsActive = YES;
    }else{
        [self selectPictureFromLibrary];
//        UIAlertView *noCamAlert = [[UIAlertView alloc]initWithTitle:@"No Camera Available" message:@"Your device does not have a camera" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [noCamAlert show];
        _captureSessionIsActive = NO;
    }
}
- (IBAction)snapStillImage:(id)sender
{
    if (_captureSessionIsActive) {
        NSOperationQueue *sessionQueue = [[NSOperationQueue alloc]init];
        
        [sessionQueue addOperationWithBlock:^{
            
            //[[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self cameraView] layer] connection] videoOrientation]];
            
            // Flash set to Auto for Still Capture
            //[AVCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
            
            // Capture a still image.
            [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                
                if (imageDataSampleBuffer)
                {
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [_session stopRunning];
                        _imageView.hidden = NO;
                        _imageView.image = image;
                        _capturedImage = _imageView.image;
                        _captureSessionIsActive = NO;
                        
#warning this method needs testing
                        [self changeImageOnParse:image];
                        
                    });
                }
            }];
            
            
        }];
    }else{
        [self initializeCamera];
    }
    
    // Update the orientation on the still image output video connection before capturing.
    
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
