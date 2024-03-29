//
//  LRShadowRoundedRect.h
//  Letter Go
//
//  Created by Gabe Nicholas on 6/29/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRShadow : NSObject
/*
 @description Use this class to build rounded rects for menus and buttons
 @param radius The width and height of the radius for the rounded rect
 @param color The color of the shadow
 @param top Whether or not the shadow appears on the top or bottom of the rounded rect
 @param height The height of the shadow
 */

+ (instancetype)shadowWithHeight:(CGFloat)height color:(UIColor *)color top:(BOOL)top radius:(CGFloat)radius;
@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) BOOL top;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) CGFloat radius;

@end
/*
 @description Use this class to build menus and buttons with shadows
 @param color The main color of the menu
 @param size The size of the menu, including its shadow
 @param shadow The shadow that the rounded rect should use
 */

@interface LRShadowRoundedRect : SKSpriteNode
- (id)initWithColor:(UIColor *)color size:(CGSize)size shadow:(LRShadow *)shadow;
@end

@interface LRShadowRoundedButton : LRShadowRoundedRect

@property (nonatomic, readonly) SEL actionTouchUpInside;
@property (nonatomic, readonly) SEL actionTouchDown;
@property (nonatomic, readonly) SEL actionTouchUp;
@property (nonatomic, readonly, weak) id targetTouchUpInside;
@property (nonatomic, readonly, weak) id targetTouchDown;
@property (nonatomic, readonly, weak) id targetTouchUp;
@property (nonatomic, readwrite, strong) SKLabelNode *titleLabel;

@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL isSelected;

- (void)setTouchUpInsideTarget:(id)target action:(SEL)action;
- (void)setTouchDownTarget:(id)target action:(SEL)action;
- (void)setTouchUpTarget:(id)target action:(SEL)action;

@end