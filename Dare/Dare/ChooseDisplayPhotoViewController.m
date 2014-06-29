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


@interface ChooseDisplayPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) BOOL frontCamera;
@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *capturedImage;
@property (nonatomic) BOOL captureSessionIsActive;

// For use in the storyboards.

@end

@implementation ChooseDisplayPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _captureSessionIsActive = NO;

    _imageView.hidden = YES;
}


- (void) initializeCamera {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
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
        UIAlertView *noCamAlert = [[UIAlertView alloc]initWithTitle:@"No Camera Available" message:@"Your device does not have a camera" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noCamAlert show];
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
                        _capturedImage = image;
                        _captureSessionIsActive = NO;
                        
                        
                        
                    });
                }
            }];
            
            
        }];
    }else{
        [self initializeCamera];
    }
    
    // Update the orientation on the still image output video connection before capturing.
    
}


@end
