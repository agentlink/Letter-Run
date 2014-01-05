//
//  LRFallingLetterList.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRFallingEnvelopeSlotManager.h"
#import "LRConstants.h"
#import "LRPositionConstants.h"
#import "LRGameStateManager.h"
#import "LRDifficultyManager.h"

static const int kSlotHistoryCapacity = 4;

@interface LRFallingEnvelopeSlotManager ()
@property (nonatomic, strong) NSMutableArray *slotHistory;
@property (nonatomic, strong) NSMutableArray *slotChanceTracker;
@property CGFloat currentZIndex;
@end

@implementation LRFallingEnvelopeSlotManager
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

- (NSMutableArray*) slotHistory {
    if (!_slotHistory) {
        _slotHistory = [NSMutableArray new];
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

- (void) addEnvelope:(LRFallingEnvelope*)envelope
{
    //Slot list
    int slotIndex = [self getIndexOfNextSlot];
    [envelope setSlot:slotIndex];
    [self addSlotHistoryObject:@(slotIndex)];
    [self setZPositionForEnvelope:envelope];
}

- (void) addSlotHistoryObject:(NSNumber*)slot
{
    if ([self.slotHistory count] == kSlotHistoryCapacity) {
        [self removeSlotLastFromHistory];
    }
    NSNumber *slotChanceToDecrease = [self.slotChanceTracker objectAtIndex:[slot intValue]];
    slotChanceToDecrease = @([slotChanceToDecrease intValue] - 1);
    [self.slotChanceTracker setObject:slotChanceToDecrease atIndexedSubscript:[slot intValue]];
    [self.slotHistory insertObject:slot atIndex:0];
}

- (void) removeSlotLastFromHistory
{
    NSNumber *slot = [self.slotHistory lastObject];
    int slotIndex = [slot intValue];
    NSNumber *slotChanceToIncrease = [self.slotChanceTracker objectAtIndex:slotIndex];
    slotChanceToIncrease = @(([slotChanceToIncrease intValue] +1));
    [self.slotChanceTracker setObject:slotChanceToIncrease atIndexedSubscript:slotIndex];
    [self.slotHistory removeObject:slot];
    
}

#pragma mark - zPosition Function

- (void) setZPositionForEnvelope:(LRFallingEnvelope*)envelope
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
    return arc4random()%kNumberOfSlots;
}



#pragma mark - Reset Functions
- (void) resetSlots
{
    [self.slotHistory removeAllObjects];
    self.currentZIndex = kEnvelopeZPositionMin;
}

@end
