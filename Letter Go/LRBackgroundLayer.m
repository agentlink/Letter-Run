//
//  LRBackgroundLayer.m
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRPositionConstants.h"
#import "LRBackgroundLayer.h"
#import "LRRowManager.h"
#import "LRMainGameSection.h"
#import "LRMovingBlockBuilder.h"
#import "LRSharedTextureCache.h"

static NSUInteger const kLRBackgroundLayerStripesPerRow = 6;
static NSString * const kLRBackgroundLayerStartScroll = @"start background scroll";
static NSString * const kLRBackgroundLayerStopScroll = @"stop background scroll";

@interface LRBackgroundLayer ()
@property SKSpriteNode *mainGameSectionBackground;
@property (nonatomic, strong) NSArray *scrollingChildren;
@end

@implementation LRBackgroundLayer

- (id) init
{
    if (self = [super initWithColor:[UIColor clearColor] size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)])
    {
        [self setPosition:CGPointMake(self.size.width/2, self.size.height/2)];
        self.mainGameSectionBackground = [[SKSpriteNode alloc] initWithColor:[LRColor mainScreenRoad]
                                                                        size:CGSizeMake(SCREEN_WIDTH, kSectionHeightMainSection)];
        NSArray *stripes = [self _stripesForRoadSprite:self.mainGameSectionBackground];
        self.scrollingChildren = [NSArray arrayWithArray:stripes];
        [self createSectionContent];
    }
    return self;
}

- (void)createSectionContent
{
    //TODO: Fix how this is done
    CGFloat mainGameSectionXPos = 0;
    CGFloat mainGameSectionYPos = -self.size.height/2 + kSectionHeightLetterSection + kSectionHeightButtonSection + kSectionHeightMainSection/2;
    self.mainGameSectionBackground.position = CGPointMake(mainGameSectionXPos, mainGameSectionYPos);
    [self addChild:self.mainGameSectionBackground];
    for (SKSpriteNode *stripe in self.scrollingChildren) {
        [self addChild:stripe];
    }
}

- (NSArray *)_stripesForRoadSprite:(SKSpriteNode *)road
{
    NSMutableArray *allStripes = [NSMutableArray new];
    //TODO: get this value correctly
    CGFloat stripeWidth = 38.5;
    CGFloat diffY = road.size.height / (kLRRowManagerNumberOfRows + 1);
    CGFloat diffX = (road.size.width + 38.5)/(kLRBackgroundLayerStripesPerRow);
    CGFloat startY = diffY - road.size.height/2;
    CGFloat xPos = (road.size.width - diffX)/2;
    CGFloat yPos = startY;
    
    for (int j = 0; j < kLRBackgroundLayerStripesPerRow; j++) {
        for (int i = 0; i < kLRRowManagerNumberOfRows; i++)
        {
            SKTexture *texture = [[LRSharedTextureCache shared] textureWithName:@"mainSection-stripe"];
            SKSpriteNode *stripe = [[SKSpriteNode alloc ] initWithTexture:texture];
            stripe.position = CGPointMake(xPos, yPos);
            stripe.yScale = 1.2;
            yPos += diffY;
            [allStripes addObject:stripe];
        }
        xPos -= diffX;
        yPos = startY;
    }
    NSAssert([(SKSpriteNode *)allStripes[0] size].width == stripeWidth, @"Stripe width value is incorrect");
    return allStripes;
}

- (void)_startStripeMovement
{
    for (SKSpriteNode *sprite in self.scrollingChildren)
    {
        [sprite removeActionForKey:kLRBackgroundLayerStopScroll];
        [self _runRecursiveMovementOnSprite:sprite];
        sprite.speed = 1.0;
    }
}

- (void)_stopStripeMovementAnimated:(BOOL)animated
{
    for (SKSpriteNode *sprite in self.scrollingChildren) {
        if (animated) {
            SKAction *slowDown = [LRMainGameSection gameOverSlowDownAction];
            SKAction *completion = [SKAction runBlock:^{
                [sprite removeActionForKey:kLRBackgroundLayerStartScroll];
            }];
            [sprite runAction:[SKAction sequence:@[slowDown, completion]] withKey:kLRBackgroundLayerStopScroll];
        }
    }
}

- (void)_runRecursiveMovementOnSprite:(SKSpriteNode *)sprite
{
    SKAction *initialMove = [self _movementForSprite:sprite];
    SKAction *completion = [SKAction runBlock:^{
        sprite.position = CGPointMake((self.mainGameSectionBackground.size.width + sprite.size.width)/2, sprite.position.y);
        [self _runRecursiveMovementOnSprite:sprite];
    }];
    [sprite runAction:[SKAction sequence:@[initialMove, completion]] withKey:kLRBackgroundLayerStartScroll];
}

- (SKAction *)_movementForSprite:(SKSpriteNode *)sprite
{
    //Get how far the stripe is from the edge
    CGFloat leftEdgeX = (self.mainGameSectionBackground.size.width + sprite.size.width)/2;
    CGPoint endPoint = CGPointMake(-leftEdgeX, sprite.position.y);
    CGFloat distance =  endPoint.x - sprite.position.x;
    //Make the duration the same as the letter cross time
    CGFloat totalCrossTime = [LRMovingBlockBuilder blockScreenCrossTime];
    CGFloat duration = ABS(distance/self.mainGameSectionBackground.size.width) * totalCrossTime;
    
    return [SKAction moveBy:CGVectorMake(distance, 0) duration:duration];
}

- (void)gameStateNewGame
{
    [self _startStripeMovement];
}

- (void)gameStateGameOver
{
    [self _stopStripeMovementAnimated:YES];
}

@end
