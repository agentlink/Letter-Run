//
//  LRSectionBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/14/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"
#import "LRLetterBlockControlDelegate.h"

extern CGFloat const kLRCollectedEnvelopeHeight;

static NSInteger const kSlotIndexNone = -1;
static NSString* const kTempCollectedEnvelopeName = @"NAME_SPRITE_SECTION_LETTER_BLOCK_TEMP";

@interface LRCollectedEnvelope : LRLetterBlock

//Envelope Initializers
+ (LRCollectedEnvelope *)sectionBlockWithLetter:(NSString *)letter loveLetter:(BOOL)love;;
+ (LRCollectedEnvelope *)emptySectionBlock;
+ (LRCollectedEnvelope *)placeholderBlock;

//Letter State
- (BOOL) isLetterBlockEmpty;
- (BOOL) isLetterBlockPlaceHolder;

@property (nonatomic, weak) id <LRLetterBlockControlDelegate> delegate;
@property (nonatomic) NSUInteger slotIndex;

@end
