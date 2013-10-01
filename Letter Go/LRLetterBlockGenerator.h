//
//  LRLetterBlockGenerator.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRLetterBlock.h"

@interface LRLetterBlockGenerator : SKNode

+ (LRLetterBlock*) createLetterBlock;
+ (LRLetterBlock*) createEmptyLetterBlock;
+ (LRLetterBlock*) createBlockForSlotWithLetter:(NSString*)letter;

@end
