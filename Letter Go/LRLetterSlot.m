//
//  LRLetterSlot.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSlot.h"
#import "LRLetterBlockGenerator.h"
#import "LRNameConstants.h"

@implementation LRLetterSlot

- (id) init
{
    if (self = [super init])
    {
        self.currentBlock = [LRLetterBlockGenerator createEmptyLetterBlock];
        self.name = NAME_EMPTY_LETTER_SLOT;
        self.size = self.currentBlock.size;
        self.color = [UIColor clearColor];
        [self addChild:self.currentBlock];
    }
    return self;
}

- (id) initWithLetterBlock:(LRLetterBlock*)block
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

- (void) setCurrentBlock:(LRLetterBlock *)incomingBlock
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
        [self addChild:_currentBlock];
    }
}
@end
