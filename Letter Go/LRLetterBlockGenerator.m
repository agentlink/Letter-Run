//
//  LRLetterBlockGenerator.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlockGenerator.h"
#import "LRDifficultyManager.h"
#import "LRLetterGenerator.h"

static const BOOL lgbDebugMode = NO;

@implementation LRLetterBlockGenerator

#pragma mark - Public Functions

+ (LRMovingBlock*) createRandomEnvelope
{
    NSString *letter = [self generateLetter];
    BOOL love = [self isLoveLetter];
    LRMovingBlock *envelope = [LRMovingBlock movingBlockWithLetter:letter loveLetter:love];
    
    envelope.position = CGPointMake(0, 160 + envelope.frame.size.height/2);
    return envelope;
}

+ (LRMovingBlock*) createRandomEnvelopeAtSlot:(int)slot
{
    LRMovingBlock *envelope = [self createRandomEnvelope];
    //Setting the slot also sets the position. For now, slots are 0 - 2
    envelope.slot = slot;
    return envelope;
}

+ (LRCollectedEnvelope*) createEmptySectionBlock
{
    LRCollectedEnvelope *lb = [LRCollectedEnvelope emptySectionBlock];
    lb.color = (lgbDebugMode) ? [SKColor purpleColor] : [LRColor clearColor];
    return lb;
}

+ (LRCollectedEnvelope*) createPlaceHolderBlock
{
    LRCollectedEnvelope *lb = [LRLetterBlockGenerator createEmptySectionBlock];
    lb.letter = kLetterPlaceHolderText;
    if (lgbDebugMode)
        lb.color = [SKColor greenColor];
    return lb;
}

+ (LRCollectedEnvelope*) createBlockWithLetter:(NSString *)letter loveLetter:(BOOL)love {
    return [LRCollectedEnvelope sectionBlockWithLetter:letter loveLetter:love];
}

#pragma mark - Private Functions

+ (BOOL) isLoveLetter
{
    int chance = arc4random()%100;
    return (chance < [[LRDifficultyManager shared] loveLetterProbability]);
}

+ (NSString*) generateLetter
{
    NSString *letter = [[LRLetterGenerator shared] generateLetter];
    return letter;
}

@end
