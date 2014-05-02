//
//  LRBackgroundLayer.m
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRPositionConstants.h"
#import "LRBackgroundLayer.h"
#import "LRSlotManager.h"
#import "LRMainGameSection.h"
#import "LRMovingBlockBuilder.h"

@interface LRBackgroundLayer ()
@property SKSpriteNode *mainGameSectionBackground;
@property (nonatomic, weak) NSArray *roadStripes;
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
    CGFloat diffY = road.size.height / (kLRSlotManagerNumberOfSlots + 1);
    CGFloat diffX = 100;
    CGFloat startY = diffY - road.size.height/2;
    CGFloat xPos = (road.size.width - diffX)/2;
    CGFloat yPos = startY;
    int stripesPerRow = road.size.width/diffX + 1;
    
    for (int j = 0; j < stripesPerRow; j++) {
        for (int i = 0; i < kLRSlotManagerNumberOfSlots; i++)
        {
            SKSpriteNode *stripe = [[SKSpriteNode alloc ] initWithImageNamed:@"mainSection-stripe"];
            stripe.position = CGPointMake(xPos, yPos);
            yPos += diffY;
            [allStripes addObject:stripe];
        }
        xPos -= diffX;
        yPos = startY;
    }
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
    SKAction *initialMove = [LRBackgroundLayer _movementForStripe:stripe];
    [stripe runAction:initialMove completion:^{
        stripe.position = CGPointMake(-(SCREEN_WIDTH/2 + stripe.size.width), stripe.position.y);
        [self _runRecursiveMovementOnStripe:stripe];
    }];
}

+ (SKAction *)_movementForStripe:(SKSpriteNode *)stripe
{
    //Get how far the stripe is from the right edge
    CGPoint endPoint = CGPointMake(SCREEN_WIDTH/2 + stripe.size.width, stripe.position.y);
    CGFloat distance = endPoint.x - stripe.position.x;
    //Make the duration the same as the letter cross time
    CGFloat totalCrossTime = [[LRMovingBlockBuilder shared] blockScreenCrossTime];
    CGFloat duration = (distance/(SCREEN_WIDTH + stripe.size.width)) * totalCrossTime;
    
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
