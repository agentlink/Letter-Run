//
//  LRMovingBlockBuilder.h
//  Letter Go
//
//  Created by Gabe Nicholas on 4/19/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRMovingEnvelope.h"

@protocol LRMovingBlockBuilderDelegate;

@interface LRMovingBlockBuilder : SKNode
+ (LRMovingBlockBuilder *)shared;
@property (nonatomic, weak) SKSpriteNode <LRMovingBlockBuilderDelegate> *delegate;
@property (nonatomic) BOOL generationPaused;

- (void)startMovingBlockGeneration;
- (void)stopMovingBlockGeneration;

@end

@protocol LRMovingBlockBuilderDelegate <NSObject>
- (void)addMovingBlockToScreen:(LRMovingEnvelope *)envelope;
@end