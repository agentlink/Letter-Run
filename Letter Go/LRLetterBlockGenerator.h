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

+ (LRFallingEnvelope*) createRandomEnvelope;
+ (LRFallingEnvelope*) createRandomEnvelopeAtSlot:(int)slot;
+ (LRSectionBlock*) createEmptySectionBlock;
+ (LRSectionBlock*) createPlaceHolderBlock;
+ (LRSectionBlock*) createBlockWithLetter:(NSString*)letter;

@end
