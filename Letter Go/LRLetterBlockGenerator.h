//
//  LRLetterBlockGenerator.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRFallingEnvelope.h"
#import "LRSectionBlock.h"

@interface LRLetterBlockGenerator : SKNode


#pragma mark - Falling Envelopes
///Create an envelope with a weighted random letter and weighted chance of being a love letter
+ (LRFallingEnvelope*) createRandomEnvelope;
///Create an envelope with a weighted random letter and weighted chance of being a love letter and put it at a slot
+ (LRFallingEnvelope*) createRandomEnvelopeAtSlot:(int)slot;

#pragma mark - Letter Section Blocks
///Create an empty slot for the letter section
+ (LRSectionBlock*) createEmptySectionBlock;
///Create a place holder block to be used during rearrangement
+ (LRSectionBlock*) createPlaceHolderBlock;
/*!
 @param letter The letter the block should have
 @param love Whether or not the letter is a love letter
 @return A new instance of a section block
 */
+ (LRSectionBlock*) createBlockWithLetter:(NSString *)letter loveLetter:(BOOL)love;

@end
