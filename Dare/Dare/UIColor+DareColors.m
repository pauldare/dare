//
//  UIColor+DareColors.m
//  Dare
//
//  Created by Test on 6/29/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "UIColor+DareColors.h"

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
@end
