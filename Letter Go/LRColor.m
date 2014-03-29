//
//  LRColor.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/28/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRColor.h"

@implementation LRColor

+ (SKColor *)rgbColorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)alpha{
    CGFloat base = 255.0;
    NSAssert(r <= base && b <= base && g <= base && alpha <= 1.0, @"Error: improper values provided to LRColor.");
    return [SKColor colorWithRed:r/base green:g/base blue:b/base alpha:alpha];
}

+ (SKColor *)colorBetweenStartColor:(UIColor *)startColor andEndColor:(UIColor *)endColor percent:(CGFloat)percent
{
    const CGFloat *startRGB = CGColorGetComponents(startColor.CGColor);
    const CGFloat *endRGB = CGColorGetComponents(endColor.CGColor);
    CGFloat r, g, b, alpha;

    r = (startRGB[0] * (1.0 - percent)) + (endRGB[0] * percent);
    g = (startRGB[1] * (1.0 - percent)) + (endRGB[1] * percent);
    b = (startRGB[2] * (1.0 - percent)) + (endRGB[2] * percent);
    alpha = (startRGB[3] * (1.0 - percent)) + (endRGB[3] * percent);
    
    return [SKColor colorWithRed:r green:g blue:b alpha:alpha];
}

//Basic colors
+ (SKColor *)clearColor {
    return [SKColor clearColor];
}
+ (SKColor *)redColor {
    return [SKColor redColor];
}

//Game screen object colors
+ (SKColor *)submitButtonEnabledColor {
    return [SKColor greenColor];
}
+ (SKColor *)submitButtonDisabledColor {
    return [SKColor lightGrayColor];
}
+ (SKColor *)submitButtonTextColor {
    return [SKColor whiteColor];
}

+ (SKColor *)emptySlotColor {
    return [LRColor clearColor];
}
+ (SKColor *)letterBlockFontColor {
    return [SKColor blackColor];
}

//Health Bar Colors
+ (SKColor *)healthBarColorGreen {
    return [SKColor colorWithRed:0.0 green:0.75 blue:0.0 alpha:1.0];
}

+ (SKColor *)healthBarColorYellow {
    return [SKColor colorWithRed:1.0 green:.9 blue:0.0 alpha:1.0];
}

+ (SKColor *)healtBarColorRed {
    return [SKColor colorWithRed:0.75 green:0.0 blue:0.0 alpha:1.0];
}

//Background object colors
+ (SKColor *)skyColor {
    return [LRColor rgbColorWithRed:135.0 green:206.0 blue:250.0 alpha:1];
}
+ (SKColor *)letterSectionColor {
    return [LRColor rgbColorWithRed:14 green:85 blue:129 alpha:.9];
}

+ (SKColor *)buttonSectionColor {
    return [LRColor rgbColorWithRed:14 green:85 blue:129 alpha:.7];
}

+ (SKColor *)gamePlayLayerBackgroundColor {
    return [SKColor whiteColor];
}

+ (SKColor *)debugColor1 {
    //Opaque green
    return [SKColor colorWithRed:0.0 green:.7 blue:.1 alpha:.3];
}

+ (SKColor *)debugColor2 {
    //Opaque red
    return [SKColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:.3];
}

+ (SKColor *)randomColorWithAlpha:(CGFloat)alpha {
    int maxVal = 256;
    return [LRColor rgbColorWithRed:arc4random()%maxVal
                              green:arc4random()%maxVal
                               blue:arc4random()%maxVal
                              alpha:alpha];
}

@end
