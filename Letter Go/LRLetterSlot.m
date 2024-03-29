//
//  LRLetterSlot.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSlot.h"
#import "LRLetterBlockBuilder.h"
#import "LRPositionConstants.h"
#import "LREnvelopeAnimationBuilder.h"

@implementation LRLetterSlot

- (id) init
{
    if (self = [super init])
    {
        self.currentBlock = [LRLetterBlockBuilder createEmptySectionBlock];
        self.size = CGSizeMake(kDistanceBetweenSlots, kSectionHeightLetterSection);
        [self addChild:self.currentBlock];
    }
    return self;
}

- (id) initWithLetterBlock:(LRCollectedEnvelope *)block
{
    if (self = [self init])
    {
        self.currentBlock = block;
    }
    return self;
}

- (BOOL) isLetterSlotEmpty
{
    return [self.currentBlock isCollectedEnvelopeEmpty];
}

- (void)stopEnvelopeChildAnimation
{
    self.currentBlock.position = CGPointZero;
}

#pragma mark - Setters and Getters

- (void)setCurrentBlock:(LRCollectedEnvelope *)incomingBlock
{
    //If it's being initialized
    if (!_currentBlock)
    {
        _currentBlock = incomingBlock;
    }
    //If a block is being deleted from a slot and is replaced by an empty block
    else
    {
        if ([_currentBlock parent] == self)
            [self removeChildrenInArray:[NSArray arrayWithObject:_currentBlock]];
        if ([incomingBlock parent])
            [incomingBlock removeFromParent];
        _currentBlock = incomingBlock;
        _currentBlock.position = CGPointZero;
        _currentBlock.slotIndex = self.index;
        _currentBlock.touchSize = self.size;
        [self addChild:_currentBlock];
    }
    _currentBlock.zPosition = zPos_SectionBlock_Unselected;
}

- (void)setEmptyLetterBlock
{
    self.currentBlock = [LRLetterBlockBuilder createEmptySectionBlock];
}

#pragma LRGameStateDelegate Functions
- (void)gameStateGameOver
{
    self.userInteractionEnabled = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
