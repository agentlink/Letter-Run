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
@property (nonatomic) BOOL generationPaused;

- (void)startMovingBlockGeneration;
- (void)stopMovingBlockGeneration;

@end

@protocol LRMovingBlockBuilderDelegate <NSObject>
- (void)addMovingBlockToScreen:(LRMovingEnvelope *)envelope;
- (void)removeMovingBlockFromScreen:(LRMovingEnvelope *)envelope;
@end