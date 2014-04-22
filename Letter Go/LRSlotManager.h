//
//  LRFallingLetterList.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//


#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>
#import "LRMovingEnvelope.h"

static const int kLRSlotManagerNumberOfSlots = 4;
@interface LRSlotManager : NSObject

///Returns the slot that the next letter should be in
- (int)generateNextSlot;
///Resets the slot values. Call this after a game over
- (void)resetLastSlot;

@end
