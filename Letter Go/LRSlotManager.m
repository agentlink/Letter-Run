//
//  LRFallingLetterList.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRSlotManager.h"
#import "LRConstants.h"
#import "LRPositionConstants.h"
#import "LRGameStateManager.h"

@implementation LRSlotManager
{
    int _lastSlot;
}
#pragma mark - Overridden Functions

- (id) init
{
    //Initialize the array as a list of arrays
    if (self = [super init]) {
        [self resetLastSlot];
    }
    return self;
}

- (int)generateNextSlot
{
    int nextSlot = _lastSlot;
    if (_lastSlot == kLRSlotManagerNumberOfSlots - 1) {
        nextSlot = kLRSlotManagerNumberOfSlots - 2;
    }
    else if (_lastSlot == 0) {
        nextSlot = 1;
    }
    else {
        BOOL rand = (BOOL)(arc4random()%2);
        nextSlot += rand ? 1 : -1;
    }
    _lastSlot = nextSlot;
    return nextSlot;
}

- (void)resetLastSlot
{
    _lastSlot = arc4random()%kLRSlotManagerNumberOfSlots;
}

@end
