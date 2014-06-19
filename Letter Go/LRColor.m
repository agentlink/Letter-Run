//
//  LRColor.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/28/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRColor.h"

@implementation LRColor

+ (LRColor *)rgbColorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)alpha{
    CGFloat base = 255.0;
    NSAssert(r <= base && b <= base && g <= base && alpha <= 1.0, @"Error: improper values provided to LRColor.");
    return (LRColor *)[SKColor colorWithRed:r/base green:g/base blue:b/base alpha:alpha];
}

+ (LRColor *)colorBetweenStartColor:(UIColor *)startColor andEndColor:(UIColor *)endColor percent:(CGFloat)percent
{
    NSAssert(percent <= 1.00, @"Percent should not exceed 1.00");
    const CGFloat *startRGB = CGColorGetComponents(startColor.CGColor);
    const CGFloat *endRGB = CGColorGetComponents(endColor.CGColor);
    CGFloat r, g, b, alpha;

    r = (startRGB[0] * (1.0 - percent)) + (endRGB[0] * percent);
    g = (startRGB[1] * (1.0 - percent)) + (endRGB[1] * percent);
    b = (startRGB[2] * (1.0 - percent)) + (endRGB[2] * percent);
    alpha = (startRGB[3] * (1.0 - percent)) + (endRGB[3] * percent);
    
    return (LRColor *)[SKColor colorWithRed:r green:g blue:b alpha:alpha];
}

+ (LRColor *)primaryColorForPaperColor:(LRPaperColor)paperColor
{
    switch (paperColor) {
        case kLRPaperColorYellow:
            return [LRColor rgbColorWithRed:254.0 green:220.0 blue:138.0 alpha:1];
            break;
        case kLRPaperColorBlue:
            return [LRColor rgbColorWithRed:148 green:217 blue:246 alpha:1];
            break;
        case kLRPaperColorPink:
            return [LRColor rgbColorWithRed:226 green:138 blue:178 alpha:1];
            break;
        default:
            return (LRColor*)[SKColor blackColor];
            break;
    }
}

+ (LRColor *)secondaryColorForPaperColor:(LRPaperColor)paperColor
{
    switch (paperColor) {
        case kLRPaperColorYellow:
            return [LRColor rgbColorWithRed:248 green:170 blue:90 alpha:1];
            break;
        case kLRPaperColorBlue:
            return [LRColor rgbColorWithRed:127 green:189 blue:230 alpha:1];
            break;
        case kLRPaperColorPink:
            return [LRColor rgbColorWithRed:194 green:110 blue:140 alpha:1];
        default:
            return (LRColor *)[SKColor grayColor];
//            NSAssert(0, @"Should not look up color for empty paper color");
            return [LRColor clearColor];
            break;
    }
    
}

//Basic colors
+ (LRColor *)clearColor {
    return (LRColor *)[SKColor clearColor];
}
+ (LRColor *)redColor {
    return (LRColor *)[SKColor redColor];
}

//Game screen object colors
+ (LRColor *)submitButtonEnabledColor {
    return (LRColor *)[SKColor greenColor];
}
+ (LRColor *)submitButtonDisabledColor {
    return (LRColor *)[SKColor lightGrayColor];
}
+ (LRColor *)submitButtonTextColor {
    return (LRColor *)[SKColor whiteColor];
}

+ (LRColor *)emptySlotColor {
    return [LRColor clearColor];
}
+ (LRColor *)letterBlockFontColor {
    return (LRColor *)[SKColor blackColor];
}

//Main Screen Colors
+ (LRColor *)mainScreenRoad
{
    return [LRColor rgbColorWithRed:178 green:180 blue:165 alpha:1];
}

//Health Bar Colors
+ (LRColor *)healthBarColorGreen {
    return [LRColor rgbColorWithRed:0.0 green:192.0 blue:0.0 alpha:1.0];
}

+ (LRColor *)healthBarColorYellow {
    return [LRColor rgbColorWithRed:255.0 green:217.0 blue:88.0 alpha:1.0];
}

+ (LRColor *)healthBarColorRed {
    return [LRColor rgbColorWithRed:192.0 green:0.0 blue:0.0 alpha:1.0];
}

//Background object colors
+ (LRColor *)gameOverLabelColor {
    return [LRColor rgbColorWithRed:179.0 green:0.0 blue:0.0 alpha:.85];
}
+ (LRColor *)skyColor {
    return [LRColor rgbColorWithRed:135.0 green:206.0 blue:250.0 alpha:1];
}
+ (LRColor *)letterSectionColor {
    return (LRColor*)[SKColor whiteColor];
}

+ (LRColor *)buttonSectionColor {
    return (LRColor*)[SKColor whiteColor];
}

+ (LRColor *)gamePlayLayerBackgroundColor {
    return (LRColor *)[SKColor clearColor];
}

+ (LRColor *)debugColor1 {
    //Opaque green
    return [LRColor rgbColorWithRed:0.0 green:179.0 blue:26.0 alpha:.3];
}

+ (LRColor *)debugColor2 {
    //Opaque red
    return [LRColor rgbColorWithRed:179.0 green:0.0 blue:0.0 alpha:0.3];
}

+ (LRColor *)randomColorWithAlpha:(CGFloat)alpha {
    int maxVal = 256;
    return [LRColor rgbColorWithRed:arc4random()%maxVal
                              green:arc4random()%maxVal
                               blue:arc4random()%maxVal
                              alpha:alpha];
}

@end
