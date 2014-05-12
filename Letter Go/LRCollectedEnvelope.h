//
//  LRSectionBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/14/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"
#import "LRLetterBlockControlDelegate.h"
@class LRLetterSlot;

extern CGFloat const kLRCollectedEnvelopeHeight;
extern NSString * const kLRCollectedEnvelopeTemporaryName;
extern NSString * const kLRCollectedEnvelopeName;

static NSInteger const kSlotIndexNone = -1;

@interface LRCollectedEnvelope : LRLetterBlock

//Envelope Initializers
+ (LRCollectedEnvelope *)collectedEnvelopeWithLetter:(NSString *)letter paperColor:(LRPaperColor)paper;
+ (LRCollectedEnvelope *)emptyCollectedEnvelope;
+ (LRCollectedEnvelope *)placeholderCollectedEnvelope;

//Letter State
- (BOOL) isCollectedEnvelopeEmpty;
- (BOOL) isCollectedEnvelopePlaceholder;

//Helper Functions
- (NSString *)stringFromPaperColor:(LRPaperColor)paperColor;
- (LRCollectedEnvelope *)animatableCopyOfEnvelope;

///This is TRUE if the envelope is at a point wherein if it is not touched, it will be deleted
@property (nonatomic) BOOL isAtDeletionPoint;
@property (nonatomic, weak) id <LRLetterBlockControlDelegate> delegate;
@property (nonatomic) NSUInteger slotIndex;
@property (nonatomic, readonly, weak) LRLetterSlot *parentSlot;

@end
