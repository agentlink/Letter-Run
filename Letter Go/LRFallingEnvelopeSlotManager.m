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
@property NSMutableArray *slotHistory;
@property CGFloat currentZIndex;
@end

@implementation LRFallingEnvelopeSlotManager
@synthesize slotHistory;
#pragma mark - Overridden Functions

- (id) init
{
    //Initialize the array as a list of arrays
    if (self = [super init]) {
        slotHistory = [NSMutableArray new];
        self.currentZIndex = kEnvelopeZPositionMin;
    }
    return self;
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
    if ([slotHistory count] == kSlotHistoryCapacity) {
        [slotHistory removeLastObject];
    }
    [slotHistory addObject:slot];
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
    [slotHistory removeAllObjects];
    self.currentZIndex = kEnvelopeZPositionMin;
}

@end
