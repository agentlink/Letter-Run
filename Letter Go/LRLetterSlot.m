//
//  LRLetterSlot.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSlot.h"
#import "LRLetterBlockGenerator.h"
#import "LRConstants.h"

@implementation LRLetterSlot

- (id) init
{
    if (self = [super init])
    {
        self.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
        self.name = NAME_LETTER_SLOT;
        self.size = self.currentBlock.size;
        self.color = [UIColor whiteColor];
        [self addChild:self.currentBlock];
    }
    return self;
}

- (id) initWithLetterBlock:(LRSectionBlock*)block
{
    if (self = [self init])
    {
        self.currentBlock = block;
    }
    return self;
}

- (BOOL) isLetterSlotEmpty
{
    return [self.currentBlock isLetterBlockEmpty];
}

- (void) setCurrentBlock:(LRSectionBlock *)incomingBlock
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
        incomingBlock.position = _currentBlock.position;
        _currentBlock = incomingBlock;
        [self addChild:_currentBlock];
    }
    _currentBlock.zPosition = self.zPosition + 10;
}

- (void) setEmptyLetterBlock
{
    self.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
}
@end
