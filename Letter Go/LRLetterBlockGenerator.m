//
//  LRLetterBlockGenerator.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlockGenerator.h"
#import "LRConstants.h"
#import "LRLetterGenerator.h"

#define PLACEHOLDER_TEXT            @" "

@implementation LRLetterBlockGenerator

#pragma mark - Falling Letters

+ (LRFallingEnvelope*) createRandomEnvelope
{
    NSString *letter = [[LRLetterGenerator shared] generateLetter];
    LRFallingEnvelope *envelope = [LRFallingEnvelope envelopeWithLetter:letter];
    envelope.position = CGPointMake(0, 200);
    return envelope;
}

+ (LRSectionBlock*) createEmptySectionBlock
{
    LRSectionBlock *lb = [LRSectionBlock sectionBlockWithLetter:@""];
    lb.color = [SKColor clearColor];
    return lb;
}

+ (LRSectionBlock*) createPlaceHolderBlock
{
    LRSectionBlock *lb = [LRLetterBlockGenerator createEmptySectionBlock];
    lb.letter = PLACEHOLDER_TEXT;
    return lb;
}

+ (LRSectionBlock*) createBlockWithLetter:(NSString*)letter
{
    LRSectionBlock *lb = [LRSectionBlock sectionBlockWithLetter:letter];
    return lb;
}
@end
