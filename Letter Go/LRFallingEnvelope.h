//
//  LRFallingEnvelope.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/14/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"

@interface LRFallingEnvelope : LRLetterBlock

typedef enum {
    BlockState_Falling,
    BlockState_PlayerIsHolding,
    BlockState_BlockFlung,
    BlockState_Landed
} BlockState;

@property BlockState blockState;
@property (nonatomic) int slot;

+ (LRFallingEnvelope*) envelopeWithLetter:(NSString*)letter;

- (void) dropEnvelopeWithSwing;
- (void) removePhysics;

- (void) envelopeHitMailman;

@end
