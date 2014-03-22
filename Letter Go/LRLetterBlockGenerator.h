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
///Create an envelope with a weighted random letter and weighted chance of being a love letter
+ (LRMovingEnvelope *)createRandomEnvelope;
///Create an envelope with a weighted random letter and weighted chance of being a love letter and put it at a slot
+ (LRMovingEnvelope *)createRandomEnvelopeAtSlot:(int)slot;

#pragma mark - Letter Section Blocks
///Create an empty slot for the letter section
+ (LRCollectedEnvelope *)createEmptySectionBlock;
///Create a place holder block to be used during rearrangement
+ (LRCollectedEnvelope *)createPlaceHolderBlock;
/*!
 @param letter The letter the block should have
 @param love Whether or not the letter is a love letter
 @return A new instance of a section block
 */
+ (LRCollectedEnvelope *)createBlockWithLetter:(NSString *)letter loveLetter:(BOOL)love;

@end
