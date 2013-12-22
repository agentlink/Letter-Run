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


@interface LRFallingEnvelopeSlotManager ()

@property NSMutableArray *slotSortedEnvelopeList;
@property NSMutableArray *timeSortedEnvelopeList;
@property CGFloat currentZIndex;


@end

@implementation LRFallingEnvelopeSlotManager
@synthesize slotSortedEnvelopeList, timeSortedEnvelopeList;
#pragma mark - Overridden Functions

- (id) init
{
    //Initialize the array as a list of arrays
    if (self = [super init]) {
        
        slotSortedEnvelopeList = [NSMutableArray new];
        timeSortedEnvelopeList = [NSMutableArray new];
        
        self.currentZIndex = kEnvelopeZPositionMin;
        
        for (int i = 0; i < kNumberOfSlots; i++) {
            [slotSortedEnvelopeList setObject:[NSMutableArray array] atIndexedSubscript:i];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeEnvelopeFromNotification:) name:NOTIFICATION_LETTER_CLEARED object:nil];
    }
    return self;
}

#pragma mark - Letter Addition and Removal

- (void) addEnvelope:(LRFallingEnvelope*)envelope
{
    //Slot list
    int slotIndex = [self getIndexOfNextSlot];
    [envelope setSlot:slotIndex];
    [self addObject:envelope atSlotIndex:slotIndex];
    
    //Time list
    [self setZPositionForEnvelope:envelope];
    [self.timeSortedEnvelopeList addObject:envelope];
}

- (void) addObject:(id)anObject atSlotIndex:(NSUInteger)index
{
    NSMutableArray *slot = [slotSortedEnvelopeList objectAtIndex:index];
    [slot addObject:anObject];
}

- (void) removeEnvelopeFromNotification:(NSNotification*)notification
{
    LRFallingEnvelope *envelope = [[notification userInfo] objectForKey:@"envelope"];
    NSAssert(envelope, @"Error: notification does not include element.");
    if (![[LRGameStateManager shared] isGameOver])
        NSAssert ([self removeEnvelope:envelope], @"Error: envelope with letter %@ is not in slot or time list.", envelope.letter);

}

- (BOOL) removeEnvelope:(LRFallingEnvelope*)envelope
{
    //Time list
    [timeSortedEnvelopeList removeObject:envelope];
    
    //Slot list
    NSMutableArray *slotArray = [slotSortedEnvelopeList objectAtIndex:envelope.slot];
    BOOL retValue = [slotArray containsObject:envelope];
    //Returns FALSE if envelope is not in the slot
    [slotArray removeObject:envelope];
    return retValue;
}

#pragma mark - zPosition Function

- (void) setZPositionForEnvelope:(LRFallingEnvelope*)envelope
{
    //If next zPosition would be in front of the grass layer, push them all back
    if (self.currentZIndex + zDiff_Envelope_Envelope >= kEnvelopeZPositionMax)
        [self pushBackZIndices];
    self.currentZIndex += zDiff_Envelope_Envelope;
    envelope.zPosition = self.currentZIndex;
    
}

- (void) pushBackZIndices
{
    //Invariant: there are less than 1 / zDiff_Envelope_Envelope letters on the screen
    for (int i = 0; i < [timeSortedEnvelopeList count]; i++) {
        LRFallingEnvelope *envelope = timeSortedEnvelopeList[i];
        self.currentZIndex = i * zDiff_Envelope_Envelope + kEnvelopeZPositionMin;
        envelope.zPosition =  self.currentZIndex;
    }
}

#pragma mark - Slot Index Functions

- (int) getIndexOfNextSlot
{
    //Get a list of the empty slots
    NSMutableArray *emptySlots = [NSMutableArray array];
    for (int i = 0; i < kNumberOfSlots; i++) {
        if (![[slotSortedEnvelopeList objectAtIndex:i] count]) {
            [emptySlots addObject:@(i)];
        }
    }
    //If there is an empty slot, return a random one of those
    if (emptySlots.count) {
        return [[emptySlots objectAtIndex:arc4random()%emptySlots.count] intValue];
    }
    
    //Otherwise, return a random slot
    //TODO: Implement method that then chooses the least full slot (or least recently dropped slot)
    return arc4random()%kNumberOfSlots;
}

#pragma mark - Reset Functions
- (void) resetSlots
{
    for (NSMutableArray *slot in slotSortedEnvelopeList) {
        [slot removeAllObjects];
    }
    [timeSortedEnvelopeList removeAllObjects];
}

@end
