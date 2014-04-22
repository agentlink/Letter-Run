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
#import "LRDifficultyManager.h"

//#toy
static CGFloat const kLRMovingBlockBuilderIntialDropInterval = 1.0;
static CGFloat const kLRMovingBlockBuilderIntervalRatio = 1.15;
static CGFloat const kLRMovingBlockBuilderCrossTime = 3.5;
@implementation LRMovingBlockBuilder

#pragma mark - Public Functions

static LRMovingBlockBuilder *_shared = nil;
+ (LRMovingBlockBuilder *)shared
{
    @synchronized (self)
    {
		if (!_shared)
        {
			_shared = [[LRMovingBlockBuilder alloc] init];
		}
	}
	return _shared;
}

- (void)startMovingBlockGeneration
{
    SKAction *delay = [SKAction waitForDuration:[LRMovingBlockBuilder _envelopeGenerationIntervalForLevel:[[LRDifficultyManager shared] level]]];
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

#pragma mark - Private Functions

- (void)_generateEnvelope
{
    LRMovingEnvelope *envelope = [LRLetterBlockBuilder createRandomEnvelope];
    //TODO: get duration from some calculation
    CGFloat distance = SCREEN_WIDTH + kCollectedEnvelopeSpriteDimension;
    SKAction *moveAcrossScreen = [SKAction moveBy:CGVectorMake(-distance, 0) duration:kLRMovingBlockBuilderCrossTime];
    [self.screenDelegate addMovingBlockToScreen:envelope];
    [envelope runAction:moveAcrossScreen];
    
    //Determines when the collection animation runs
    CGFloat collectionPause = kLRMovingBlockBuilderCrossTime* (SCREEN_WIDTH/distance);
    SKAction *pauseForCollectionCheck = [SKAction waitForDuration:collectionPause];
    
    [envelope runAction:pauseForCollectionCheck completion:^{
        SKAction *removalAction = envelope.selected ? [LRMovingBlockBuilder _collectedAction] : [LRMovingBlockBuilder _discardedAction];
        [envelope runAction:removalAction completion:^{
            if (envelope.selected) {
                [self.letterAdditionDelegate addEnvelopeToLetterSection:envelope];
            }
            [self.screenDelegate removeMovingBlockFromScreen:envelope];
        }];
    }];
}

+ (CGFloat)_envelopeGenerationIntervalForLevel:(int)level
{
    return kLRMovingBlockBuilderIntialDropInterval/powf(kLRMovingBlockBuilderIntervalRatio, level - 1);
}

+ (SKAction *)_collectedAction
{
    SKAction *fade = [SKAction fadeAlphaTo:0 duration:.3];
    return fade;
}

+ (SKAction *)_discardedAction
{
    SKAction *moveOff = [SKAction moveBy:CGVectorMake(-kCollectedEnvelopeSpriteDimension, 0)
                                duration:kLRMovingBlockBuilderCrossTime * (SCREEN_WIDTH/kCollectedEnvelopeSpriteDimension)];
    return moveOff;
}

@end
