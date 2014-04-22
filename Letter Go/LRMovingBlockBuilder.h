//
//  LRMovingBlockBuilder.h
//  Letter Go
//
//  Created by Gabe Nicholas on 4/19/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRMovingEnvelope.h"
#import "LRLetterBlockControlDelegate.h"

@protocol LRMovingBlockBuilderDelegate;

@interface LRMovingBlockBuilder : SKNode
+ (LRMovingBlockBuilder *)shared;
@property (nonatomic, weak) id <LRMovingBlockBuilderDelegate> screenDelegate;
@property (nonatomic, weak) id <LRLetterBlockControlDelegate> letterAdditionDelegate;

- (void)startMovingBlockGeneration;
- (void)stopMovingBlockGeneration;
///Returns the time difference in seconds between how often blocks are being generated
- (CGFloat)blockGenerationInterval;
///Returns how long it takes the block to move across the screen
- (CGFloat)blockScreenCrossTime;

@end

@protocol LRMovingBlockBuilderDelegate <NSObject>
- (void)addMovingBlockToScreen:(LRMovingEnvelope *)envelope;
- (void)removeMovingBlockFromScreen:(LRMovingEnvelope *)envelope;
@end