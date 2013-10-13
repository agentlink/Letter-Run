//
//  LRLetterBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRObject.h"

typedef enum {
    BlockState_Falling,
    BlockState_PlayerIsHolding,
    BlockState_BlockFlung,
    BlockState_InLetterSlot,
    BlockState_Rearranging
} BlockState;

@interface LRLetterBlock : LRObject
@property NSString *letter;

+ (LRLetterBlock*) letterBlockWithSize:(CGSize)size andLetter:(NSString*)letter;

- (BOOL) isLetterBlockEmpty;
- (BOOL) isLetterBlockPlaceHolder;

- (void) setUpPhysics;
- (void) setUpSwipedPhysics;
- (void) removePhysics;

@property CGPoint originalPoint;
@property BOOL vertMovementEnabled;
@property BlockState blockState;
@property BOOL blockInLetterSection;

@end
