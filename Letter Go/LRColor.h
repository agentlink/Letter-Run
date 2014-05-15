//
//  LRColor.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/28/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface LRColor : SKColor

///Returns a color with the RGB values provided. Values must be below 255
+ (LRColor *)rgbColorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)alpha;
///Returns a color with RGB values between the start and the end point by a given percentage
+ (LRColor *)colorBetweenStartColor:(UIColor *)startColor andEndColor:(UIColor *)endColor percent:(CGFloat)percent;

//Basic colors
+ (LRColor *)clearColor;
+ (LRColor *)redColor;

//Health bar colors
+ (LRColor *)healthBarColorGreen;
+ (LRColor *)healthBarColorYellow;
+ (LRColor *)healthBarColorRed;

//Submit button colors
+ (LRColor *)submitButtonEnabledColor;
+ (LRColor *)submitButtonDisabledColor;
+ (LRColor *)submitButtonTextColor;

//Main Screen Colors
+ (LRColor *)mainScreenRoad;

//Other colors
+ (LRColor *)gameOverLabelColor;
+ (LRColor *)emptySlotColor;
+ (LRColor *)letterBlockFontColor;
+ (LRColor *)skyColor;
+ (LRColor *)letterSectionColor;
+ (LRColor *)buttonSectionColor;
+ (LRColor *)gamePlayLayerBackgroundColor;

+ (LRColor *)debugColor1;
+ (LRColor *)debugColor2;
+ (LRColor *)randomColorWithAlpha:(CGFloat)alpha;

@end
