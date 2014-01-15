//
//  LRFallingEnvelopeSlotManager_Private.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/11/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRSlotManager.h"
#import "LRCappedStack.h"
@interface LRSlotManager ()

@property (nonatomic, strong) LRCappedStack *slotHistory;
@property (nonatomic, strong) NSMutableArray *slotChanceTracker;
@property CGFloat currentZIndex;

@end
