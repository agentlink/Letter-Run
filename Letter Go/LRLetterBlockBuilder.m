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
#import "LRProgressManager.h"

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
    lb.color = (lgbDebugMode) ? [SKColor purpleColor] : [UIColor clearColor];
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
    LRMission *mission = [[LRProgressManager shared] currentMission];
    NSMutableDictionary *probabilityDict = [NSMutableDictionary new];
    NSInteger maxVal = 0;
    
    //get all the probabilities and load them into a dictionary
    for (LRPaperColor color = 0; color <= kLRPaperColorHighestValue; color++)
    {
        NSInteger probability = [mission probabilityForEnvelopeColor:color];
        if (probability != 0)
        {
            maxVal += probability;
            NSString *strColor = [LRLetterBlock stringValueForPaperColor:color];
            [probabilityDict setObject:@(maxVal) forKey:strColor];
        }
    }
    //sort the dictionary by value order so we can add them into the plist however we'd like
    NSArray *sortedKeys = [probabilityDict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSInteger v1 = [obj1 integerValue];
        NSInteger v2 = [obj2 integerValue];
        if (v1 < v2)
            return NSOrderedAscending;
        else if (v1 > v2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    //generate the value
    NSInteger val = arc4random()%maxVal + 1;
    //and compare it ot the values in the dictionary
    for (NSString *key in sortedKeys)
    {
        NSInteger probVal = [probabilityDict[key] integerValue];
        if (probVal >= val)
        {
            return [LRLetterBlock paperColorForString:key];
        }
    }
    NSAssert(0, @"Unable to find paper color for given probabilities");
    return kLRPaperColorNone;
}

+ (NSString *)generateLetterForPaperColor:(LRPaperColor)paperColor
{
    NSString *letter = [[LRAlphabeticalLetterGenerator shared] generateLetterForPaperColor:paperColor];
    return letter;
}

@end
