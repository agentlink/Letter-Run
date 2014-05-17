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


static NSUInteger const kLRBackgroundLayerStripesPerRow = 6;

@interface LRBackgroundLayer ()
@property SKSpriteNode *mainGameSectionBackground;
@property (nonatomic, strong) NSArray *roadStripes;
@end

@implementation LRBackgroundLayer

- (id) init
{
    if (self = [super initWithColor:[UIColor clearColor] size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)])
    {
        [self setPosition:CGPointMake(self.size.width/2, self.size.height/2)];
        self.mainGameSectionBackground = [[SKSpriteNode alloc] initWithColor:[LRColor mainScreenRoad]
                                                                        size:CGSizeMake(SCREEN_WIDTH, kSectionHeightMainSection)];
        self.roadStripes = [self _stripesForRoadSprite:self.mainGameSectionBackground];
        [self createSectionContent];
    }
    return self;
}

- (void)createSectionContent
{
    //TODO: Fix how this is done
    CGFloat mainGameSectionXPos = 0;
    CGFloat mainGameSectionYPos = (kSectionHeightLetterSection + kSectionHeightHealthSection + kSectionHeightButtonSection)/2;
    self.mainGameSectionBackground.position = CGPointMake(mainGameSectionXPos, mainGameSectionYPos);
    [self addChild:self.mainGameSectionBackground];
    for (SKSpriteNode *stripe in self.roadStripes) {
        [self.mainGameSectionBackground addChild:stripe];
    }
    [self startStripeMovement];
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
            SKSpriteNode *stripe = [[SKSpriteNode alloc ] initWithImageNamed:@"mainSection-stripe"];
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

- (void)startStripeMovement
{
    for (SKSpriteNode *stripe in self.roadStripes) {
        [self _runRecursiveMovementOnStripe:stripe];
    }
}

- (void)_runRecursiveMovementOnStripe:(SKSpriteNode *)stripe
{
    SKAction *initialMove = [self _movementForStripe:stripe];
    [stripe runAction:initialMove completion:^{
        stripe.position = CGPointMake((self.mainGameSectionBackground.size.width + stripe.size.width)/2, stripe.position.y);
        [self _runRecursiveMovementOnStripe:stripe];
    }];
}

- (SKAction *)_movementForStripe:(SKSpriteNode *)stripe
{
    //Get how far the stripe is from the edge
    CGFloat leftEdgeX = (self.mainGameSectionBackground.size.width + stripe.size.width)/2;
    CGPoint endPoint = CGPointMake(-leftEdgeX, stripe.position.y);
    CGFloat distance =  endPoint.x - stripe.position.x;
    //Make the duration the same as the letter cross time
    CGFloat totalCrossTime = [[LRMovingBlockBuilder shared] blockScreenCrossTime];
    CGFloat duration = ABS(distance/self.mainGameSectionBackground.size.width) * totalCrossTime;
    
    return [SKAction moveBy:CGVectorMake(distance, 0) duration:duration];
}

- (void)gameStatePaused
{
    self.paused = YES;
}

- (void)gameStateUnpaused
{
    self.paused = NO;
}

@end
