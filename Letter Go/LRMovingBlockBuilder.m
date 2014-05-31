//
//  LRMovingBlockBuilder.m
//  Letter Go
//
//  Created by Gabe Nicholas on 4/19/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMovingBlockBuilder.h"
#import "LRLetterBlockBuilder.h"
#import "LRGameStateManager.h"
#import "LRProgressManager.h"

//#toy
static CGFloat const kLRMovingBlockBuilderIntialDropInterval = .85;
static CGFloat const kLRMovingBlockBuilderIntervalRatio = 1.05;
static CGFloat const kLRMovingBlockBuilderCrossTime = 3.5;
@implementation LRMovingBlockBuilder

#pragma mark - Public Functions

- (void)startMovingBlockGeneration
{
    SKAction *delay = [SKAction waitForDuration:[LRMovingBlockBuilder blockGenerationInterval]];
    SKAction *generate = [SKAction runBlock:^{
        [self _generateEnvelope];
    }];
    SKAction *generateWithDelay = [SKAction sequence:@[generate, delay]];
    [self runAction:generateWithDelay completion:^{
        [self startMovingBlockGeneration];
    }];
}

- (void)stopMovingBlockGeneration
{
    [self removeAllActions];
}

+ (CGFloat)blockGenerationInterval
{
    NSUInteger level = [[LRProgressManager shared] level];
    return kLRMovingBlockBuilderIntialDropInterval/powf(kLRMovingBlockBuilderIntervalRatio, level - 1);
}

+ (CGFloat)blockScreenCrossTime
{
    return kLRMovingBlockBuilderCrossTime;
}

#pragma mark - Private Functions

- (void)_generateEnvelope
{
    LRMovingEnvelope *envelope = [LRLetterBlockBuilder createRandomEnvelope];
    //TODO: get duration from some calculation
    CGFloat distance = SCREEN_WIDTH + kCollectedEnvelopeSpriteDimension;
    CGFloat duration = [LRMovingBlockBuilder blockScreenCrossTime] * distance/SCREEN_WIDTH;
    SKAction *moveAcrossScreen = [SKAction moveBy:CGVectorMake(-distance, 0) duration:duration];
    [self.screenDelegate addMovingBlockToScreen:envelope];
    [envelope runAction:moveAcrossScreen];
    
    //Determines when the collection animation runs
    CGFloat collectionPause = kLRMovingBlockBuilderCrossTime* (SCREEN_WIDTH/distance);
    SKAction *pauseForCollectionCheck = [SKAction waitForDuration:collectionPause];
    
    [envelope runAction:pauseForCollectionCheck completion:^{
        SKAction *removalAction = envelope.selected ? [self _collectedAction] : [self _discardedAction];
        [envelope updateForRemoval];
        [envelope runAction:removalAction completion:^{
            if (envelope.selected) {
                [self.letterAdditionDelegate addEnvelopeToLetterSection:envelope];
            }
            [self.screenDelegate removeMovingBlockFromScreen:envelope];
        }];
    }];
}

- (SKAction *)_collectedAction
{
    SKAction *fade = [SKAction fadeAlphaTo:0 duration:.3];
    return fade;
}

- (SKAction *)_discardedAction
{
    SKAction *moveOff = [SKAction moveBy:CGVectorMake(-kCollectedEnvelopeSpriteDimension, 0)
                                duration:[LRMovingBlockBuilder blockScreenCrossTime] * (SCREEN_WIDTH/kCollectedEnvelopeSpriteDimension)];
    return moveOff;
}

@end
