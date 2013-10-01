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
    //If a block is being deleted from a slot
    else if ([_currentBlock isLetterBlockEmpty] && (!incomingBlock || [incomingBlock isLetterBlockEmpty]))
    {
        [self removeChildrenInArray:[NSArray arrayWithObject:_currentBlock]];
        _currentBlock = [LRLetterBlockGenerator createEmptyLetterBlock];
    }
    //If a block is being added to a slot that was previously empty
    else if ([_currentBlock isLetterBlockEmpty] && ![incomingBlock isLetterBlockEmpty])
    {
        _currentBlock = incomingBlock;
        [self addChild:_currentBlock];
    }
}
@end
