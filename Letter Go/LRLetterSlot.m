//
//  LRLetterSlot.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSlot.h"
#import "LRLetterBlockGenerator.h"
#import "LRPositionConstants.h"
#import "LREnvelopeAnimationBuilder.h"

@implementation LRLetterSlot

- (id) init
{
    if (self = [super init])
    {
        self.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
        self.name = NAME_SPRITE_LETTER_SLOT;
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
    if (self.currentBlock) {
        [self.currentBlock removeActionForKey:kAddLetterAnimationName];
        [self enumerateChildNodesWithName:kTempCollectedEnvelopeName usingBlock:^(SKNode *node, BOOL *stop){
            [node removeFromParent];
        }];
    }
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
    self.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
}

#pragma LRGameStateDelegate Functions
- (void)gameStateGameOver
{
    self.userInteractionEnabled = NO;
}
@end
