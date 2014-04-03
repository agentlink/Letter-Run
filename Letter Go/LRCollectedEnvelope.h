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
+ (LRCollectedEnvelope *)collectedEnvelopeWithLetter:(NSString *)letter loveLetter:(BOOL)love;;
+ (LRCollectedEnvelope *)emptyCollectedEnvelope;
+ (LRCollectedEnvelope *)placeholderCollectedEnvelope;

//Letter State
- (BOOL) isCollectedEnvelopeEmpty;
- (BOOL) isCollectedEnvelopePlaceholder;

///This is TRUE if the envelope is at a point wherein if it is not touched, it will be deleted
@property (nonatomic) BOOL isAtDeletionPoint;
@property (nonatomic, weak) id <LRLetterBlockControlDelegate> delegate;
@property (nonatomic) NSUInteger slotIndex;

@end
