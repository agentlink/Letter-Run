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

static const int kSlotHistoryCapacity = 5;

@interface LRSlotManager : NSObject

- (void)resetSlots;
- (void)addEnvelope:(LRMovingEnvelope *)envelope;

@end
