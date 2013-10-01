//
//  LRLetterSlot.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSlot.h"
#import "LRLetterBlockGenerator.h"
#import "LRSpriteNameConstants.h"

@implementation LRLetterSlot
@synthesize currentBlock;

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

/*
- (void) setCurrentBlock:(LRLetterBlock *)new_currentBlock
{
    self.currentBlock = new_currentBlock;
}
 */
@end
