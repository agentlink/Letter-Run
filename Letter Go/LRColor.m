//
//  LRColor.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/28/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRColor.h"

@implementation LRColor

+ (SKColor*) rgbColorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)alpha{
    //                                     initWithColor:[SKColor colorWithRed:174.0/255.0 green:227.0/255.0 blue:248.0/255.0 alpha:1]
    CGFloat base = 255.0;
    
    NSAssert(r <= base && b <= base && g <= base && alpha <= 1.0, @"Error: improper values provided to LRColor.");
    return [SKColor colorWithRed:r/base green:g/base blue:b/base alpha:alpha];
}

//Basic colors
+ (SKColor*) clearColor {
    return [SKColor clearColor];
}
+ (SKColor*) redColor {
    return [SKColor redColor];
}

//Game screen object colors
+ (SKColor*) healthBarColor {
    return [SKColor redColor];
}

+ (SKColor*) submitButtonEnabledColor {
    return [SKColor greenColor];
}
+ (SKColor*) submitButtonDisabledColor {
    return [SKColor redColor];
}
+ (SKColor*) submitButtonTextColor {
    return [SKColor whiteColor];
}

+ (SKColor*) emptySlotColor {
    return [SKColor whiteColor];
}
+ (SKColor*) letterBlockFontColor {
    return [SKColor blackColor];
}

//Background object colors
+ (SKColor*) skyColor {
    return [LRColor rgbColorWithRed:174.0 green:227.0 blue:248.0 alpha:1];
}
+ (SKColor*) letterSectionColor {
    return [LRColor rgbColorWithRed:152.0 green:104.0 blue:63.0 alpha:1];
}

@end
