//
//  LRLetterSlot.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRCollectedEnvelope.h"

@interface LRLetterSlot : SKSpriteNode

@property (nonatomic, strong) LRCollectedEnvelope *currentBlock;
@property (nonatomic) NSInteger index;

- (id) initWithLetterBlock:(LRCollectedEnvelope*)block;
- (void) setEmptyLetterBlock;
- (BOOL) isLetterSlotEmpty;

@end
