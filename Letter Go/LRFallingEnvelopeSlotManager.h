//
//  LRFallingLetterList.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRFallingEnvelope.h"

#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>

static const int kSlotHistoryCapacity = 5;

@interface LRFallingEnvelopeSlotManager : NSObject

- (void) resetSlots;
- (void) addEnvelope:(LRFallingEnvelope*)envelope;

@end
