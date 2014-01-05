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

@implementation LRLetterBlockGenerator

#pragma mark - Public Functions

+ (LRFallingEnvelope*) createRandomEnvelope
{
    NSString *letter = [self generateLetter];
    BOOL love = [self isLoveLetter];
    LRFallingEnvelope *envelope = [LRFallingEnvelope envelopeWithLetter:letter loveLetter:love];
    
    envelope.position = CGPointMake(0, 160 + envelope.frame.size.height/2);
    return envelope;
}

+ (LRFallingEnvelope*) createRandomEnvelopeAtSlot:(int)slot
{
    LRFallingEnvelope *envelope = [self createRandomEnvelope];
    //Setting the slot also sets the position. For now, slots are 0 - 2
    envelope.slot = slot;
    return envelope;
}

+ (LRSectionBlock*) createEmptySectionBlock
{
    LRSectionBlock *lb = [LRSectionBlock emptySectionBlock];
    lb.color = [LRColor clearColor];
    return lb;
}

+ (LRSectionBlock*) createPlaceHolderBlock
{
    LRSectionBlock *lb = [LRLetterBlockGenerator createEmptySectionBlock];
    lb.letter = LETTER_PLACEHOLDER_TEXT;
    return lb;
}

+ (LRSectionBlock*) createBlockWithLetter:(NSString *)letter loveLetter:(BOOL)love {
    return [LRSectionBlock sectionBlockWithLetter:letter loveLetter:love];
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
