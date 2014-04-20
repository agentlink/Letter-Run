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
    SKAction *moveAcrossScreen = [SKAction moveBy:CGVectorMake(-SCREEN_WIDTH, 0) duration:3];
    
    [self.screenDelegate addMovingBlockToScreen:envelope];
    [envelope runAction:moveAcrossScreen completion:^{
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
    SKAction *moveOff = [SKAction moveBy:CGVectorMake(-kCollectedEnvelopeSpriteDimension, 0) duration:.2];
    moveOff.timingMode = SKActionTimingEaseOut;
    return moveOff;
}

@end
