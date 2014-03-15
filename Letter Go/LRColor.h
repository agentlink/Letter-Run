//
//  LRColor.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/28/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface LRColor : NSObject

///Returns a color with the RGB values provided. Values must be below 255
+ (SKColor *)rgbColorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)alpha;
///Returns a color with RGB values between the start and the end point by a given percentage
+ (SKColor *)colorBetweenStartColor:(UIColor *)startColor andEndColor:(UIColor *)endColor percent:(CGFloat)percent;

//Basic colors
+ (SKColor *)clearColor;
+ (SKColor *)redColor;

//Health bar colors
+ (SKColor *)healthBarColorGreen;
+ (SKColor *)healthBarColorYellow;
+ (SKColor *)healtBarColorRed;

//Submit button colors
+ (SKColor *)submitButtonEnabledColor;
+ (SKColor *)submitButtonDisabledColor;
+ (SKColor *)submitButtonTextColor;

//Other colors
+ (SKColor *)emptySlotColor;
+ (SKColor *)letterBlockFontColor;
+ (SKColor *)skyColor;
+ (SKColor *)letterSectionColor;
+ (SKColor *)gamePlayLayerBackgroundColor;
@end
