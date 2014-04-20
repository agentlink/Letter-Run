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
///The player has selected the envelope while on the main game screen
@property (nonatomic) BOOL selected;

+ (LRMovingEnvelope *)movingBlockWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor;

@end

@protocol LRMovingBlockTouchDelegate <NSObject>

- (void)playerSelectedMovingBlock:(LRMovingEnvelope *)movingBlock;

@end