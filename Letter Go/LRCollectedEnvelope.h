//
//  LRSectionBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/14/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"
#import "LRLetterBlockControlDelegate.h"

static const NSInteger kSlotIndexNone = -1;

@interface LRCollectedEnvelope : LRLetterBlock

+ (LRCollectedEnvelope*) sectionBlockWithLetter:(NSString*)letter loveLetter:(BOOL)love;;
+ (LRCollectedEnvelope*) emptySectionBlock;

- (void) envelopeHitBottomBarrier;

- (BOOL) isLetterBlockEmpty;
- (BOOL) isLetterBlockPlaceHolder;

@property (nonatomic, weak) id <LRLetterBlockControlDelegate> delegate;
@property (nonatomic) BOOL physicsEnabled;
@property (nonatomic) NSInteger slotIndex;

@end
