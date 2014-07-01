//
//  CameraManager.m
//  Dare
//
//  Created by Nadia Yudina on 6/30/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "CameraManager.h"

@implementation CameraManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.captureSessionIsActive = NO;
    }
    return self;
}

- (void) initializeCameraForImageView: (UIImageView *)imageView
                              isFront: (BOOL)isFronCamera
                                 view: (UIView *)cameraView
                              failure: (void(^)())failure
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        imageView.hidden = YES;
        self.session = [[AVCaptureSession alloc] init];
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        captureVideoPreviewLayer.frame = cameraView.bounds;
        [cameraView.layer addSublayer:captureVideoPreviewLayer];
        
        NSArray *devices = [AVCaptureDevice devices];
        AVCaptureDevice *camera;
        
        for (AVCaptureDevice *device in devices) {
            
            if ([device hasMediaType:AVMediaTypeVideo]) {
                
                if (isFronCamera) {
                    if ([device position] == AVCaptureDevicePositionFront) {
                        
                        camera = device;
                    }
                } else {
                    if ([device position] == AVCaptureDevicePositionBack) {
                        
                        camera = device;
                    }
                }
            }
        }
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:camera
                                                                            error:&error];
        
        [self.session addInput:input];
        
        
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        
        [self.session addOutput:self.stillImageOutput];
        
        [self.session startRunning];
        self.captureSessionIsActive = YES;
    }else{
        failure();
        
        //        UIAlertView *noCamAlert = [[UIAlertView alloc]initWithTitle:@"No Camera Available" message:@"Your device does not have a camera" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //        [noCamAlert show];
        
        self.captureSessionIsActive = NO;
    }
}


- (void)snapStillImageForImageView: (UIImageView *)imageView
                           isFront: (BOOL)isFront
                              view: (UIView *)view
                        completion: (void(^)(UIImage *))completion
                           failure: (void(^)())failure
{
    if (self.captureSessionIsActive) {
        NSOperationQueue *sessionQueue = [[NSOperationQueue alloc]init];
        
//        [sessionQueue addOperationWithBlock:^{
        
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
                        
                        [self.session stopRunning];
                        imageView.hidden = NO;
                        imageView.image = image;
                        self.capturedImage = imageView.image;
                        self.captureSessionIsActive = NO;
                        completion(image);
                        
                    });
                }
            }];
//        }];
    }else{
        [self initializeCameraForImageView:imageView
                                   isFront:isFront
                                      view:view
                                   failure:^{
            failure();
        }];
    }
}






@end
