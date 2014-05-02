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
///If this is YES, show the open letter sprite
@property (nonatomic) BOOL envelopeOpen;

+ (LRMovingEnvelope *)movingBlockWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor;
+ (NSString *)stringFromPaperColor:(LRPaperColor)paperColor open:(BOOL)open;


@end

@protocol LRMovingBlockTouchDelegate <NSObject>

- (void)playerSelectedMovingBlock:(LRMovingEnvelope *)movingBlock;

@end