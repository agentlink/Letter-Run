//
//  LRMovingBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"

@protocol LRMovingBlockTouchDelegate;
@interface LRMovingEnvelope : LRLetterBlock

@property (nonatomic, weak) id<LRMovingBlockTouchDelegate> touchDelegate;
@property (nonatomic) NSUInteger slot;
+ (LRMovingEnvelope *)movingBlockWithLetter:(NSString *)letter loveLetter:(BOOL)love;

@end

@protocol LRMovingBlockTouchDelegate <NSObject>

- (void)playerSelectedMovingBlock:(LRMovingEnvelope *)movingBlock;

@end