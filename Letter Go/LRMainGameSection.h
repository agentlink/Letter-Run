//
//  LRMainGameSection.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRScreenSection.h"
#import "LRMovingBlock.h"

@protocol LRLetterAdditionDelegate;
@interface LRMainGameSection : LRScreenSection

///Setting this pauses and unpauses the movement of letters
@property (nonatomic) BOOL envelopeMovementPaused;
@property (nonatomic) BOOL envelopeTouchEnabled;
@property (nonatomic, weak) id <LRLetterAdditionDelegate> letterAdditionDelegate;

- (void) addMovingBlockToScreen:(LRMovingBlock*)movingBlock;
- (void) clearMainGameSection;

@end


@protocol LRLetterAdditionDelegate <NSObject>

- (void) addEnvelopeToLetterSection:(LRMovingBlock*)envelope;

@end
