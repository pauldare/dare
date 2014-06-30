//
//  CameraManager.h
//  Dare
//
//  Created by Nadia Yudina on 6/30/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraManager : NSObject

@property (nonatomic) BOOL captureSessionIsActive;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) UIImage *capturedImage;


- (void) initializeCameraForImageView: (UIImageView *)imageView
                              isFront: (BOOL)isFronCamera
                                 view: (UIView *)cameraView
                              failure: (void(^)())failure;


- (void)snapStillImageForImageView: (UIImageView *)imageView
                           isFront: (BOOL)isFront
                              view: (UIView *)view
                        completion: (void(^)(UIImage *))completion
                           failure: (void(^)())failure;

@end
