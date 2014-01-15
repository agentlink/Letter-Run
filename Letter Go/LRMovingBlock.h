//
//  LRMovingBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"

@protocol LRMovingBlockTouchDelegate;
@interface LRMovingBlock : LRLetterBlock

@property (nonatomic, weak) id<LRMovingBlockTouchDelegate> touchDelegate;
@property (nonatomic) NSUInteger slot;

+ (LRMovingBlock*) movingBlockWithLetter:(NSString*)letter loveLetter:(BOOL)love;

//Remove this
- (NSDictionary*)addLetterDictionary;

@end

@protocol LRMovingBlockTouchDelegate <NSObject>

- (void) playerSelectedMovingBlock:(LRMovingBlock*)movingBlock;

@end