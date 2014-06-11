//
//  LRLetterBlockGenerator.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlockBuilder.h"
#import "LRAlphabeticalLetterGenerator.h"
#import "LRDifficultyManager.h"
typedef NS_ENUM(NSInteger, LRLetterProbability) {
    kLRLetterProbabilityCommon          = 20,
    kLRLetterProbabilityUncommon        = 23,
    kLRLetterProbabilityRare            = 25,
};

static const BOOL lgbDebugMode = NO;

@implementation LRLetterBlockBuilder

#pragma mark - Public Functions

+ (LRMovingEnvelope *)createRandomEnvelope
{
    LRPaperColor paperColor = [self generatePaperColor];
    NSString *letter = [self generateLetterForPaperColor:paperColor];
    LRMovingEnvelope *envelope = [LRMovingEnvelope movingBlockWithLetter:letter paperColor:paperColor];
    
    envelope.position = CGPointMake(0, 160 + envelope.frame.size.height/2);
    return envelope;
}

+ (LRMovingEnvelope *)createRandomEnvelopeAtSlot:(int)slot
{
    LRMovingEnvelope *envelope = [self createRandomEnvelope];
    //Setting the slot also sets the position. For now, slots are 0 - 2
    envelope.row = slot;
    return envelope;
}

+ (LRCollectedEnvelope *)createEmptySectionBlock
{
    LRCollectedEnvelope *lb = [LRCollectedEnvelope emptyCollectedEnvelope];
    lb.userInteractionEnabled = NO;
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
    int maxVal = kLRLetterProbabilityRare + 1;
    int val = arc4random()%maxVal;
    
    LRPaperColor paperColor;
    if (val <= kLRLetterProbabilityCommon) {
        paperColor = kLRPaperColorYellow;
    }
    else if (val <= kLRLetterProbabilityUncommon) {
        paperColor = kLRPaperColorPink;
    }
    else {
        paperColor = kLRPaperColorBlue;
    }
    
    if (![LRLetterBlockBuilder _isPaperColorEnabled:paperColor]) {
        paperColor = [LRLetterBlockBuilder generatePaperColor];
    }
    return paperColor;
}

+ (BOOL)_isPaperColorEnabled:(LRPaperColor)color
{
    NSNumber *newColorVal = @(color);
    return [[[LRDifficultyManager shared] availablePaperColors] containsObject:newColorVal];
}

+ (NSString *)generateLetterForPaperColor:(LRPaperColor)paperColor
{
    NSString *letter = [[LRAlphabeticalLetterGenerator shared] generateLetterForPaperColor:paperColor];
    return letter;
}

@end
