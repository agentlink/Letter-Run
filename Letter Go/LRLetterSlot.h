//
//  LRLetterSlot.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRLetterBlock.h"

@interface LRLetterSlot : SKSpriteNode

@property (nonatomic) LRLetterBlock *currentBlock;

- (BOOL) isLetterSlotEmpty;

@end
