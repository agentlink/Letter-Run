//
//  LRMainGameSection.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRScreenSection.h"
#import "LRMovingBlock.h"
@interface LRMainGameSection : LRScreenSection

///Setting this pauses and unpauses the movement of letters
@property (nonatomic) BOOL envelopeMovementPaused;

- (void) addMovingBlockToScreen:(LRMovingBlock*)movingBlock;
//TODO: implement this
- (void) clearMainGameSection;
@end
