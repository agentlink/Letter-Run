//
//  LRFallingLetterList.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRRowManager.h"
#import "LRConstants.h"
#import "LRPositionConstants.h"
#import "LRGameStateManager.h"

@implementation LRRowManager
{
    int _lastSlot;
}
#pragma mark - Overridden Functions

- (id) init
{
    //Initialize the array as a list of arrays
    if (self = [super init]) {
        [self resetLastRow];
    }
    return self;
}

- (int)generateNextRow
{
    int nextSlot = _lastSlot;
    if (_lastSlot == kLRRowManagerNumberOfRows - 1) {
        nextSlot = kLRRowManagerNumberOfRows - 2;
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

- (void)resetLastRow
{
    _lastSlot = arc4random()%kLRRowManagerNumberOfRows;
}

@end
