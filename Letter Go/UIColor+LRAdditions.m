//
//  UIColor+LRAdditions.m
//  Letter Go
//
//  Created by Gabe Nicholas on 7/3/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "UIColor+LRAdditions.h"

@implementation UIColor (LRAdditions)

+ (UIColor *)rgbColorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)alpha{
    CGFloat base = 255.0;
    NSAssert(r <= base && b <= base && g <= base && alpha <= 1.0, @"Error: improper values provided to UIColor.");
    return [UIColor colorWithRed:r/base green:g/base blue:b/base alpha:alpha];
}

+ (UIColor *)colorBetweenStartColor:(UIColor *)startColor andEndColor:(UIColor *)endColor percent:(CGFloat)percent
{
    NSAssert(percent <= 1.00, @"Percent should not exceed 1.00");
    const CGFloat *startRGB = CGColorGetComponents(startColor.CGColor);
    const CGFloat *endRGB = CGColorGetComponents(endColor.CGColor);
    CGFloat r, g, b, alpha;
    
    r = (startRGB[0] * (1.0 - percent)) + (endRGB[0] * percent);
    g = (startRGB[1] * (1.0 - percent)) + (endRGB[1] * percent);
    b = (startRGB[2] * (1.0 - percent)) + (endRGB[2] * percent);
    alpha = (startRGB[3] * (1.0 - percent)) + (endRGB[3] * percent);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

+ (UIColor *)primaryColorForPaperColor:(LRPaperColor)paperColor
{
    switch (paperColor) {
        case kLRPaperColorYellow:
            return [UIColor rgbColorWithRed:254.0 green:220.0 blue:138.0 alpha:1];
            break;
        case kLRPaperColorBlue:
            return [UIColor rgbColorWithRed:148 green:217 blue:246 alpha:1];
            break;
        case kLRPaperColorPink:
            return [UIColor rgbColorWithRed:226 green:138 blue:178 alpha:1];
            break;
        case kLRPaperColorGreen:
            return [UIColor greenColor];
            break;
        default:
            return [UIColor blackColor];
            break;
    }
}

+ (UIColor *)secondaryColorForPaperColor:(LRPaperColor)paperColor
{
    switch (paperColor) {
        case kLRPaperColorYellow:
            return [UIColor rgbColorWithRed:248 green:170 blue:90 alpha:1];
            break;
        case kLRPaperColorBlue:
            return [UIColor rgbColorWithRed:127 green:189 blue:230 alpha:1];
            break;
        case kLRPaperColorPink:
            return [UIColor rgbColorWithRed:194 green:110 blue:140 alpha:1];
            break;
        case kLRPaperColorGreen:
            return [UIColor rgbColorWithRed:110 green:254 blue:186 alpha:1];
            break;
        default:
            return [UIColor grayColor];
            //            NSAssert(0, @"Should not look up color for empty paper color");
            return [UIColor clearColor];
            break;
    }
    
}

//Game screen object colors
+ (UIColor *)submitButtonEnabledColor {
    return [UIColor greenColor];
}
+ (UIColor *)submitButtonDisabledColor {
    return [UIColor lightGrayColor];
}
+ (UIColor *)submitButtonTextColor {
    return [UIColor whiteColor];
}

+ (UIColor *)buttonLightBlue {
    return [UIColor rgbColorWithRed:178.0 green:215.0 blue:228.0 alpha:1];
}

+ (UIColor *)buttonDarkBlue {
    return [UIColor rgbColorWithRed:125.0 green:188.0 blue:232.0 alpha:1.0];
}

+ (UIColor *)textDarkBlue {
    return [UIColor rgbColorWithRed:30.0 green:79.0 blue:115.0 alpha:1.0];
}

+ (UIColor *)textOrange {
    return [UIColor rgbColorWithRed:239.0 green:81.0 blue:46.0 alpha:1.0];
}

+ (UIColor *)emptySlotColor {
    return [UIColor clearColor];
}
+ (UIColor *)letterBlockFontColor {
    return [UIColor blackColor];
}

//Main Screen Colors
+ (UIColor *)mainScreenRoad
{
    return [UIColor rgbColorWithRed:178 green:180 blue:165 alpha:1];
}

//Health Bar Colors
+ (UIColor *)healthBarColorGreen {
    return [UIColor rgbColorWithRed:0.0 green:192.0 blue:0.0 alpha:1.0];
}

+ (UIColor *)healthBarColorYellow {
    return [UIColor rgbColorWithRed:255.0 green:217.0 blue:88.0 alpha:1.0];
}

+ (UIColor *)healthBarColorRed {
    return [UIColor rgbColorWithRed:192.0 green:0.0 blue:0.0 alpha:1.0];
}

//Background object colors
+ (UIColor *)gameOverLabelColor {
    return [UIColor rgbColorWithRed:179.0 green:0.0 blue:0.0 alpha:.85];
}
+ (UIColor *)skyColor {
    return [UIColor rgbColorWithRed:135.0 green:206.0 blue:250.0 alpha:1];
}
+ (UIColor *)letterSectionColor {
    return [UIColor whiteColor];
}

+ (UIColor *)buttonSectionColor {
    return [UIColor whiteColor];
}

+ (UIColor *)gamePlayLayerBackgroundColor {
    return [UIColor clearColor];
}

+ (UIColor *)dropShadowColor
{
    return [UIColor colorWithWhite:.6 alpha:.5];
}

+ (UIColor *)debugColor1 {
    //Opaque green
    return [UIColor rgbColorWithRed:0.0 green:179.0 blue:26.0 alpha:.3];
}

+ (UIColor *)debugColor2 {
    //Opaque red
    return [UIColor rgbColorWithRed:179.0 green:0.0 blue:0.0 alpha:0.3];
}

+ (UIColor *)randomColorWithAlpha:(CGFloat)alpha {
    int maxVal = 256;
    return [UIColor rgbColorWithRed:arc4random()%maxVal
                              green:arc4random()%maxVal
                               blue:arc4random()%maxVal
                              alpha:alpha];
}

@end
