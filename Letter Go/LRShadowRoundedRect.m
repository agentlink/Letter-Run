//
//  LRShadowRoundedRect.m
//  Letter Go
//
//  Created by Gabe Nicholas on 6/29/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRShadowRoundedRect.h"
#import <objc/message.h>

@interface LRShadowRoundedRect ()
@property (nonatomic, strong) SKSpriteNode *bodySprite;
@property (nonatomic, strong) SKSpriteNode *shadowSprite;
@end

@implementation LRShadowRoundedRect

- (id)initWithColor:(UIColor *)color size:(CGSize)size shadow:(LRShadow *)shadow
{
    if (self = [super initWithColor:[UIColor clearColor] size:size])
    {
        _bodySprite = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor]
                                                  size:CGSizeMake(size.width, size.height - shadow.height)];
        _bodySprite.anchorPoint = CGPointMake(0.5, 0);
        _bodySprite.position = CGPointMake(0, -self.size.height/2 + (shadow.height * !shadow.top));
        
        //round the corners on the body
        CGRect bodyShapeRect = CGRectMake(0, 0, _bodySprite.size.width, _bodySprite.size.height);
        SKShapeNode *bodyShape = [SKShapeNode node];
        [bodyShape setPath:CGPathCreateWithRoundedRect(bodyShapeRect, shadow.radius, shadow.radius, nil)];
        bodyShape.strokeColor = bodyShape.fillColor = color;
        bodyShape.position = CGPointMake(-_bodySprite.size.width/2, 0);
        [_bodySprite addChild:bodyShape];

        //round the corners on the shadow
        CGFloat shadowYPos = (shadow.top) ? self.size.height/2 - shadow.height : -self.size.height/2 - (shadow.height * shadow.top);
        _shadowSprite = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor]
                                                    size:CGSizeMake(self.size.width, shadow.height)];
        _shadowSprite.anchorPoint = CGPointMake(0.5, 0);
        _shadowSprite.position = CGPointMake(0, shadowYPos);
        
        //round the corners on the shadow
        CGRect shadowShapeRect = CGRectMake(0, 0, _shadowSprite.size.width, _bodySprite.size.height);
        SKShapeNode *shadowShape = [SKShapeNode node];
        [shadowShape setPath:CGPathCreateWithRoundedRect(shadowShapeRect, shadow.radius, shadow.radius, nil)];
        shadowShape.strokeColor = shadowShape.fillColor = shadow.color;
        shadowShape.position = CGPointMake(-_shadowSprite.size.width/2, ((shadow.height -_bodySprite.size.height) * shadow.top));
        [_shadowSprite addChild:shadowShape];

        [self addChild:_shadowSprite];
        [self addChild:_bodySprite];

    }
    return self;
}

@end

@interface LRShadow ()
@end

@implementation LRShadow
+ (instancetype)shadowWithHeight:(CGFloat)height color:(UIColor *)color top:(BOOL)top radius:(CGFloat)radius;
{
    LRShadow *shadow = [[LRShadow alloc] initWithHeight:height color:color top:top radius:radius];
    return shadow;
}

- (id)initWithHeight:(CGFloat)height color:(UIColor *)color top:(BOOL)top radius:(CGFloat)radius
{
    if (self = [super init])
    {
        _top = top;
        _color = color;
        _height = height;
        _radius = radius;
    }
    return self;
}
@end



@interface LRShadowRoundedButton ()
@property (nonatomic, strong) LRShadow *shadow;
@end
@implementation LRShadowRoundedButton

- (id)initWithColor:(UIColor *)color size:(CGSize)size shadow:(LRShadow *)shadow
{
    if (self = [super initWithColor:color size:size shadow:shadow])
    {
        _shadow = shadow;
        _isEnabled = YES;
        _isSelected = NO;
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (void)setIsEnabled:(BOOL)isEnabled
{
    _isEnabled = isEnabled;
    NSAssert(isEnabled, @"Disabled %@ buttons have not been implemented", [self class]);
}

- (void)setIsSelected:(BOOL)isSelected {
    if (_isSelected != isSelected)
    {
        CGFloat heightDiff = (isSelected != self.shadow.top) ? -self.shadow.height : self.shadow.height;
        self.bodySprite.position = CGPointMake(self.bodySprite.position.x, self.bodySprite.position.y + heightDiff);
    }
    _isSelected = isSelected;
}

- (void)setTitleLabel:(SKLabelNode *)titleLabel
{
    NSAssert(!_titleLabel, @"Cannot set title label twice");
    _titleLabel = titleLabel;
    [_titleLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [_titleLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    
    _titleLabel.position = CGPointMake(self.bodySprite.position.x, self.bodySprite.size.height/2);
    [self.bodySprite addChild:_titleLabel];

}
/* * * * * * * * * * * */

#pragma mark - LRButton Methods -

#pragma mark Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        objc_msgSend(_targetTouchDown, _actionTouchDown);
        [self setIsSelected:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInNode:self.parent];
        
        if (CGRectContainsPoint(self.frame, touchPoint)) {
            [self setIsSelected:YES];
        } else {
            [self setIsSelected:NO];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self.parent];
    
    if ([self isEnabled] && CGRectContainsPoint(self.frame, touchPoint)) {
        objc_msgSend(_targetTouchUpInside, _actionTouchUpInside);
    }
    [self setIsSelected:NO];
    objc_msgSend(_targetTouchUp, _actionTouchUp);
}

#pragma mark Setting Target-Action pairs

- (void)setTouchUpInsideTarget:(id)target action:(SEL)action {
    _targetTouchUpInside = target;
    _actionTouchUpInside = action;
}

- (void)setTouchDownTarget:(id)target action:(SEL)action {
    _targetTouchDown = target;
    _actionTouchDown = action;
}

- (void)setTouchUpTarget:(id)target action:(SEL)action {
    _targetTouchUp = target;
    _actionTouchUp = action;
}

@end

