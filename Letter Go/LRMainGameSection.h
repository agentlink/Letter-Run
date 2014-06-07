//
//  LRMainGameSection.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRScreenSection.h"
#import "LRMovingEnvelope.h"
#import "LRLetterBlockControlDelegate.h"
#import "LRMovingBlockBuilder.h"

@interface LRMainGameSection : LRScreenSection <LRMovingBlockBuilderDelegate>

///Setting this pauses and unpauses the movement of letters
@property (nonatomic) BOOL envelopeMovementPaused;
@property (nonatomic) BOOL envelopeTouchEnabled;
@property (nonatomic, strong) LRMovingBlockBuilder *envelopeBuilder;

- (void)addMovingBlockToScreen:(LRMovingEnvelope *)movingBlock;
- (void)clearMainGameSection;

+ (SKAction *)gameOverSlowDownAction;

@end
