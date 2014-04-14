//
//  LRLetterBlockGenerator.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRCollectedEnvelope.h"
#import "LRMovingEnvelope.h"

@interface LRLetterBlockGenerator : SKNode


#pragma mark - Falling Envelopes
///Create an envelope with a weighted random letter and weighted chance of being any give paper color
+ (LRMovingEnvelope *)createRandomEnvelope;
///Create an envelope with a weighted random letter and weighted chance of being a paper color and put it at a slot
+ (LRMovingEnvelope *)createRandomEnvelopeAtSlot:(int)slot;

#pragma mark - Letter Section Blocks
///Create an empty slot for the letter section
+ (LRCollectedEnvelope *)createEmptySectionBlock;
///Create a place holder block to be used during rearrangement
+ (LRCollectedEnvelope *)createPlaceHolderBlock;
/*!
 @param letter The letter the block should have
 @param paperColor The color paper and correllated score value for an envelopeØ
 @return A new instance of a section block
 */
+ (LRCollectedEnvelope *)createBlockWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor;

@end
