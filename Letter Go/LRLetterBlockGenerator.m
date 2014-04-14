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

+ (LRMovingEnvelope *)createRandomEnvelope
{
    NSString *letter = [self generateLetter];
    LRPaperColor paperColor = [self generatePaperColor];
    LRMovingEnvelope *envelope = [LRMovingEnvelope movingBlockWithLetter:letter paperColor:paperColor];
    
    envelope.position = CGPointMake(0, 160 + envelope.frame.size.height/2);
    return envelope;
}

+ (LRMovingEnvelope *)createRandomEnvelopeAtSlot:(int)slot
{
    LRMovingEnvelope *envelope = [self createRandomEnvelope];
    //Setting the slot also sets the position. For now, slots are 0 - 2
    envelope.slot = slot;
    return envelope;
}

+ (LRCollectedEnvelope *)createEmptySectionBlock
{
    LRCollectedEnvelope *lb = [LRCollectedEnvelope emptyCollectedEnvelope];
    lb.color = (lgbDebugMode) ? [SKColor purpleColor] : [LRColor clearColor];
    return lb;
}

+ (LRCollectedEnvelope *)createPlaceHolderBlock
{
    LRCollectedEnvelope *lb = [LRCollectedEnvelope placeholderCollectedEnvelope];
    return lb;
}

+ (LRCollectedEnvelope *)createBlockWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor {
    return [LRCollectedEnvelope collectedEnvelopeWithLetter:letter paperColor:paperColor];
}

#pragma mark - Private Functions

+ (LRPaperColor)generatePaperColor
{
    return arc4random()%(kLRPaperColorYellow + 1);
}

+ (NSString *)generateLetter
{
    NSString *letter = [[LRLetterGenerator shared] generateLetter];
    return letter;
}

@end
