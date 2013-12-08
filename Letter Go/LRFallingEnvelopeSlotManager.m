//
//  LRFallingLetterList.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRFallingEnvelopeSlotManager.h"
#import "LRConstants.h"

static const int NUM_SLOTS = 4;

@interface LRFallingEnvelopeSlotManager ()
@property NSMutableArray *slotList;
@end

@implementation LRFallingEnvelopeSlotManager
@synthesize slotList;
#pragma mark - Overridden Functions

- (id) init
{
    //Initialize the array as a list of arrays
    if (self = [super init]) {
        slotList = [[NSMutableArray alloc] init];
        for (int i = 0; i < NUM_SLOTS; i++) {
            [slotList setObject:[NSMutableArray array] atIndexedSubscript:i];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeEnvelopeFromNotification:) name:NOTIFICATION_LETTER_CLEARED object:nil];
    }
    return self;
}

#pragma mark - Letter Addition and Removal

- (void) addEnvelope:(LRFallingEnvelope*)envelope
{
    int slotIndex = [self getIndexOfNextSlot];
    [envelope setSlot:slotIndex];
    [self addObject:envelope atSlotIndex:slotIndex];
}

- (void) addObject:(id)anObject atSlotIndex:(NSUInteger)index
{
    NSMutableArray *slot = [slotList objectAtIndex:index];
    [slot addObject:anObject];
}

- (void) removeEnvelopeFromNotification:(NSNotification*)notification
{
    LRFallingEnvelope *envelope = [[notification userInfo] objectForKey:@"envelope"];
    NSAssert(envelope, @"Error: notification does not include element.");
    NSAssert ([self removeEnvelope:envelope], @"Error: envelope with letter %@ is not in list", envelope.letter);
}

- (BOOL) removeEnvelope:(LRFallingEnvelope*)envelope
{
    NSMutableArray *slotArray = [slotList objectAtIndex:envelope.slot];
    BOOL retValue = [slotArray containsObject:envelope];

    //Returns FALSE if envelope is not in the slot
    [slotArray removeObject:envelope];
    return retValue;
}

#pragma mark - Slot Index Functions

- (int) getIndexOfNextSlot
{
    //Get a list of the empty slots
    NSMutableArray *emptySlots = [NSMutableArray array];
    for (int i = 0; i < NUM_SLOTS; i++) {
        if (![[slotList objectAtIndex:i] count]) {
            [emptySlots addObject:@(i)];
        }
    }
    //If there is an empty slot, return a random one of those
    if (emptySlots.count) {
        return [[emptySlots objectAtIndex:arc4random()%emptySlots.count] intValue];
    }
    
    //Otherwise, return a random slot
    //TODO: Implement method that then chooses the least full slot (or least recently dropped slot)
    return arc4random()%NUM_SLOTS;
}

#pragma mark - Reset Functions
- (void) resetSlots
{
    for (NSMutableArray *slot in slotList) {
        [slot removeAllObjects];
    }
}

@end
