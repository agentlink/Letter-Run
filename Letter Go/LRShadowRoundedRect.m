//
//  LRShadowRoundedRect.m
//  Letter Go
//
//  Created by Gabe Nicholas on 6/29/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRShadowRoundedRect.h"

@implementation LRShadowRoundedRect
- (id)initWithColor:(UIColor *)color size:(CGSize)size shadow:(LRShadow *)shadow
{
    if (self = [super initWithColor:[UIColor clearColor] size:size])
    {
        CGRect mainMaskRect = CGRectMake(0, 0, size.width, size.height - shadow.height);
        SKShapeNode *mainShape = [SKShapeNode node];
        [mainShape setPath:CGPathCreateWithRoundedRect(mainMaskRect, shadow.radius.width, shadow.radius.height, nil)];
        mainShape.fillColor = mainShape.strokeColor = color;
        mainShape.position = CGPointMake(-self.size.width/2, -self.size.height/2);

        CGRect shadowRect = CGRectMake(0, 0, size.width, size.height);
        SKShapeNode *shadowShape = [SKShapeNode node];
        [shadowShape setPath:CGPathCreateWithRoundedRect(shadowRect, shadow.radius.width, shadow.radius.height, nil)];
        shadowShape.fillColor = shadowShape.strokeColor = shadow.color;
        shadowShape.position = CGPointMake(-self.size.width/2, -self.size.height/2);
        
        [self addChild:shadowShape];
        [self addChild:mainShape];
 
//        SKSpriteNode *spriteNode = [[SKSpriteNode alloc] initWithColor:color size:size];
//        SKCropNode *cropNode = [SKCropNode node];
//        SKShapeNode *mask = [SKShapeNode node];
//        CGRect maskRect = CGRectMake(-shadow.height, -shadow.height, size.width, size.height);
//        [mask setPath:CGPathCreateWithRoundedRect(maskRect, shadow.radius.width, shadow.radius.height, nil)];
//        [mask setFillColor:shadow.color];
//        [cropNode setMaskNode:mask];
//        [cropNode addChild:spriteNode];
//        [self addChild:cropNode];
    }
    return self;
}

//SKShapeNode* tile = [SKShapeNode node];
//[tile setPath:CGPathCreateWithRoundedRect(CGRectMake(-15, -15, 30, 30), 4, 4, nil)];
//tile.strokeColor = tile.fillColor = [UIColor colorWithRed:0.0/255.0
//                                                    green:128.0/255.0
//                                                     blue:255.0/255.0
//                                                    alpha:1.0];

//SKCropNode* cropNode = [SKCropNode node];
//SKShapeNode* mask = [SKShapeNode node];
//[mask setPath:CGPathCreateWithRoundedRect(CGRectMake(-15, -15, 30, 30), 4, 4, nil)];
//[mask setFillColor:[SKColor whiteColor]];
//[cropNode setMaskNode:mask];
//[cropNode addChild:tile];
@end

@interface LRShadow ()
@property (nonatomic, readwrite) CGSize radius;
@property (nonatomic, readwrite) UIColor *color;
@property (nonatomic, readwrite) BOOL top;
@property (nonatomic, readwrite) CGFloat height;
@end

@implementation LRShadow
+ (instancetype)shadowWithRadius:(CGSize)radius color:(UIColor *)color top:(BOOL)top height:(CGFloat)height
{
    LRShadow *shadow = [LRShadow new];
    shadow.radius = radius;
    shadow.top = top;
    shadow.color = color;
    shadow.height = height;
    return shadow;
}
@end