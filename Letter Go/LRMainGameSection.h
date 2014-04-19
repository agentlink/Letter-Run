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
#import "LRMailmanArea.h"
#import "LRMovingBlockBuilder.h"

@interface LRMainGameSection : LRScreenSection <LRMovingBlockBuilderDelegate>

@property (nonatomic, strong) LRMailmanArea *mailmanArea;
///Setting this pauses and unpauses the movement of letters
@property (nonatomic) BOOL envelopeMovementPaused;
@property (nonatomic) BOOL envelopeTouchEnabled;
@property (nonatomic, weak) id <LRLetterBlockControlDelegate> letterAdditionDelegate;

- (void)addMovingBlockToScreen:(LRMovingEnvelope *)movingBlock;
- (void)clearMainGameSection;

@end
