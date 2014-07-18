//
//  UIColor+DareColors.m
//  Dare
//
//  Created by Test on 6/29/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+DareColors.h"
#import <Accelerate/Accelerate.h>

@implementation UIColor (DareColors)

+(UIColor *)DareBlue
{
    return [UIColor colorWithRed:0 green:0.84 blue:1.0 alpha:1.0];
}

+(UIColor *)DareTranslucentBlue
{
    return [UIColor colorWithRed:0 green:0.84 blue:1.0 alpha:0.4];
}

+(UIColor *)DareCellOverlay
{
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
}

+(UIColor *)DareCellOverlaySolid
{
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
}

+(UIColor *)DareUnreadBadge
{
    return [UIColor colorWithRed:1.0 green:.33 blue:.05 alpha:1.0];
}

+(UIColor *)DareOverlaySeletcedCell
{
    return [UIColor colorWithRed:1.0 green:1.0 blue:0 alpha:0.4];
}

+(UIColor *)DareLightGreen
{
    return [UIColor colorWithRed:0 green:128 blue:128 alpha:0.4];
}

+(UIColor *)DarePurpleComment
{
    return [UIColor colorWithRed:0.54 green:0.32 blue:0.64 alpha:1.0];
}

+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 100);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer,
                                       &outBuffer,
                                       NULL,
                                       0,
                                       0,
                                       boxSize,
                                       boxSize,
                                       NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
//    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
//    [filter setValue:inputImage forKey:kCIInputImageKey];
//    [filter setValue:[NSNumber numberWithFloat:30.0f] forKey:@"inputRadius"];
//    CIImage *result = [filter valueForKey:kCIOutputImageKey];
//    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
//    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
//    CGImageRelease(cgImage);
//    return returnImage;
}


@end
