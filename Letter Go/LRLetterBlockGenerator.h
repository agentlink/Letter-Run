//
//  LRLetterBlockGenerator.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRLetterBlock.h"
#import "LRLetterSlot.h"

@interface LRLetterBlockGenerator : SKNode

+ (LRLetterBlock*) createLetterBlock;
+ (LRLetterBlock*) createEmptyLetterBlock;
+ (LRLetterBlock*) createPlaceHolderBlock;
+ (LRLetterBlock*) createBlockForSlotWithLetter:(NSString*)letter;

+ (LRLetterSlot*) createSlotWithLetterBlock:(LRLetterBlock*)block;
+ (LRLetterSlot*) createSlotWithLetter:(NSString*)letter;
+ (LRLetterSlot*) createSlotWithEmptyLetterBlock;
@end
