//
//  UIColor+LRAdditions.h
//  Letter Go
//
//  Created by Gabe Nicholas on 7/3/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRLetterBlock.h"

@interface UIColor (LRAdditions)

///Returns a color with the RGB values provided. Values must be below 255
+ (UIColor *)rgbColorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)alpha;
///Returns a color with RGB values between the start and the end point by a given percentage
+ (UIColor *)colorBetweenStartColor:(UIColor *)startColor andEndColor:(UIColor *)endColor percent:(CGFloat)percent;
///Returns the main color on an envelope for a given paper color
+ (UIColor *)primaryColorForPaperColor:(LRPaperColor)paperColor;
///Returns the flap color on an envelope for a given paper color
+ (UIColor *)secondaryColorForPaperColor:(LRPaperColor)paperColor;

//Health bar colors
+ (UIColor *)healthBarColorGreen;
+ (UIColor *)healthBarColorYellow;
+ (UIColor *)healthBarColorRed;

//Submit button colors
+ (UIColor *)submitButtonEnabledColor;
+ (UIColor *)submitButtonDisabledColor;
+ (UIColor *)submitButtonTextColor;

//General Buttons
+ (UIColor *)buttonLightBlue;
+ (UIColor *)buttonDarkBlue;

//Main Screen Colors
+ (UIColor *)mainScreenRoad;

//Other colors
+ (UIColor *)gameOverLabelColor;
+ (UIColor *)emptySlotColor;
+ (UIColor *)letterBlockFontColor;
+ (UIColor *)skyColor;
+ (UIColor *)letterSectionColor;
+ (UIColor *)buttonSectionColor;
+ (UIColor *)gamePlayLayerBackgroundColor;
+ (UIColor *)textDarkBlue;
+ (UIColor *)textOrange;
+ (UIColor *)dropShadowColor;

+ (UIColor *)debugColor1;
+ (UIColor *)debugColor2;
+ (UIColor *)randomColorWithAlpha:(CGFloat)alpha;

@end
