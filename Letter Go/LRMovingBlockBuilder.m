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

- (void)setGenerationPaused:(BOOL)generationPaused
{
    _generationPaused = generationPaused;
    self.paused = generationPaused;
}

#pragma mark - Private Functions

- (void)_generateEnvelope
{
    LRMovingEnvelope *envelope = [LRLetterBlockBuilder createRandomEnvelope];
    NSLog(@"Adding moving block: %@", envelope.letter);
    SKAction *moveAcrossScreen = [SKAction moveBy:CGVectorMake(-500, 0) duration:3.5];
    [self.delegate addMovingBlockToScreen:envelope];
    [envelope runAction:moveAcrossScreen];

}

+ (CGFloat)_envelopeGenerationIntervalForLevel:(int)level
{
    return kLRMovingBlockBuilderIntialDropInterval/powf(kLRMovingBlockBuilderIntervalRatio, level - 1);
}

@end
