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
#import "LRDifficultyManager.h"
#import "LRCappedStack.h"
#import "LRSlotManager_Private.h"

static const int kNilSlotValue = -1;
static const CGFloat kEnvelopeZPositionMin = zPos_FallingEnvelope;
static const CGFloat kEnvelopeZPositionMax = zPos_Mailman;

@implementation LRSlotManager
#pragma mark - Overridden Functions

- (id) init
{
    //Initialize the array as a list of arrays
    if (self = [super init]) {
        self.currentZIndex = kEnvelopeZPositionMin;
    }
    return self;
}

#pragma mark - Private Properties

- (LRCappedStack*) slotHistory {
    if (!_slotHistory) {
        _slotHistory = [[LRCappedStack alloc] initWithCapacity:kSlotHistoryCapacity];
    }
    return _slotHistory;
}

- (NSMutableArray*) slotChanceTracker {
    if (!_slotChanceTracker) {
        _slotChanceTracker = [NSMutableArray new];
        for (int i = 0; i < kNumberOfSlots; i++) {
            [_slotChanceTracker addObject:@(kSlotHistoryCapacity)];
        }
    }
    return _slotChanceTracker;
}

#pragma mark - Letter Addition

- (void) addEnvelope:(LRMovingBlock*)envelope
{
    int slotIndexToDecrease = [self getIndexOfNextSlot];
    int slotIndexToIncrease = kNilSlotValue;

    [envelope setSlot:slotIndexToDecrease];
    [self setZPositionForEnvelope:envelope];
    
    //Push the slot and get the number to decrease
    NSNumber *slotToIncrease = [self.slotHistory pushObject:@(slotIndexToDecrease)];

    //If the slot history is full...
    if (slotToIncrease) {
        //Push an object onto the history stack and see if anything gets popped off
        slotIndexToIncrease = [slotToIncrease intValue];
    }
        //Manage the slot chances
        [self increaseChanceForSlot:slotIndexToIncrease
                 andDecreaseForSlot:slotIndexToDecrease];
}

- (void) increaseChanceForSlot:(int)increase andDecreaseForSlot:(int)decrease
{


    //Decrease the chance for one slot...
    NSNumber *decreaseSlotOldValue = [self.slotChanceTracker objectAtIndex:decrease];
    NSNumber *newDecreasedValue = @([decreaseSlotOldValue intValue] - 1);
    [self.slotChanceTracker setObject:newDecreasedValue atIndexedSubscript:decrease];
    
    //...and possibly increase the chance for another
    if (increase != kNilSlotValue) {
        NSNumber *increaseSlotOldValue = [self.slotChanceTracker objectAtIndex:increase];
        //Increase one slot value...
        NSNumber *newIncreasedValue = @([increaseSlotOldValue intValue] + 1);
        [self.slotChanceTracker setObject:newIncreasedValue atIndexedSubscript:increase];
    }
}

#pragma mark - zPosition Function

- (void) setZPositionForEnvelope:(LRMovingBlock*)envelope
{
    /*
     NOTE: Reaching this condition would take about 40 minutes of play. If this point ever got
     reached, then newer letters would be behind older letters until all the letters on the
     screen before this condition got reached flew away. It is such a deep bounds case
     that it's not worth adding an observer to check for it.
     */
    if (self.currentZIndex + zDiff_Envelope_Envelope >= kEnvelopeZPositionMax)
        self.currentZIndex = kEnvelopeZPositionMin;
    self.currentZIndex += zDiff_Envelope_Envelope;
    envelope.zPosition = self.currentZIndex;
    
}

#pragma mark - Next Slot Functions

- (int) getIndexOfNextSlot
{
    //If the slot history is not filled, generate slots randomly
    if ([self.slotHistory count] != kSlotHistoryCapacity) {
        return arc4random()%kNumberOfSlots;
    }
    int maxRandValue = (kNumberOfSlots - 1) * kSlotHistoryCapacity ;
    int randValue = arc4random()%maxRandValue + 1;
    int iterator = 0;
    for (int i = 0; i < [self.slotChanceTracker count]; i++) {
        int slotChance = [[self.slotChanceTracker objectAtIndex:i] intValue];
        iterator += slotChance;
        if (iterator >= randValue) {
            return i;
        }
    }
    NSAssert(0, @"Error: slot decision function went outside bounds", randValue);
    return arc4random()%kNumberOfSlots;
}



#pragma mark - Reset Functions

- (void) resetSlots
{
    self.slotHistory = nil;
    self.slotChanceTracker = nil;
    self.currentZIndex = kEnvelopeZPositionMin;
}

@end
