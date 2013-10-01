//
//  LRLetterBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRCharacter.h"

@interface LRLetterBlock : LRCharacter
@property NSString *letter;

+ (LRLetterBlock*) letterBlockWithSize:(CGSize)size andLetter:(NSString*)letter;
- (BOOL) isLetterBlockEmpty;

- (void) setUpPhysics;
- (void) setUpSwipedPhysics;
- (void) removePhysics;

@property CGPoint originalPoint;
@property BOOL movementEnabled;
@property BOOL blockFlung;

@end
