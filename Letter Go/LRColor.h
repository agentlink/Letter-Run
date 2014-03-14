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

//Basic colors
+ (SKColor *)clearColor;
+ (SKColor *)redColor;

//Game screen object colors
+ (SKColor *)healthBarColor;
+ (SKColor *)healthBarBackgroundColor;

+ (SKColor *)submitButtonEnabledColor;
+ (SKColor *)submitButtonDisabledColor;
+ (SKColor *)submitButtonTextColor;

+ (SKColor *)emptySlotColor;
+ (SKColor *)letterBlockFontColor;

//Background object colors
+ (SKColor *)skyColor;
+ (SKColor *)letterSectionColor;


//Font colors

@end
