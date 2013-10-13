//
//  LRLetterSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSection.h"
#import "LRLetterSlot.h"
#import "LRConstants.h"
#import "LRLetterBlockGenerator.h"
#import "LRSubmitButton.h"
#import "LRScoreManager.h"
#import "LRDictionaryChecker.h"

#define LETTER_MINIMUM_COUNT        3

@interface LRLetterSection ()

@property SKSpriteNode *letterSection;
@property LRSubmitButton *submitButton;
@property NSMutableArray *letterSlots;
@property NSTimer *rearrangementTimer;
@property LRLetterSlot *currentSlot;
@end

@implementation LRLetterSection

#pragma mark - Set Up

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.currentState = LetterSectionStateNormal;
        [self setUpNotifications];
    }
    return self;
}

- (void) setUpNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLetterToSection:) name:NOTIFICATION_ADDED_LETTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLetterFromSection:) name:NOTIFICATION_DELETE_LETTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitWord) name:NOTIFICATION_SUBMIT_WORD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rearrangementScheduler:) name:NOTIFICATION_REARRANGE_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRearrangement:) name:NOTIFICATION_REARRANGE_FINISH object:nil];


}

- (void) createSectionContent
{
    //The color will be replaced by a health bar sprite
    self.letterSection = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:self.size];
    [self addChild:self.letterSection];
    self.letterSlots = [[NSMutableArray alloc] initWithCapacity:LETTER_CAPACITY];
    
    
    //Create the letter slots
    for (int i = 0; i < LETTER_CAPACITY; i++)
    {
        LRLetterSlot *slot = [[LRLetterSlot alloc] init];
        slot.position = CGPointMake([self xPosFromSlotIndex:i], 0);
        [self.letterSlots addObject:slot];
        [self addChild:slot];
    }
    
    //Create submit button
    LRSubmitButton *submitButton = [[LRSubmitButton alloc] initWithColor:[SKColor lightGrayColor] size:[[self.letterSlots objectAtIndex:0] size]];
    submitButton.position = CGPointMake([self xPosFromSlotIndex:LETTER_CAPACITY], 0);
    self.submitButton = submitButton;
    [self addChild:submitButton];
}

- (CGFloat) xPosFromSlotIndex:(int) index {
    float slotMargin, edgeBuffer;
    slotMargin = (IS_IPHONE_5) ? LETTER_BLOCK_SIZE/3.3 : LETTER_BLOCK_SIZE/4;
    edgeBuffer = (self.size.width - (slotMargin + LETTER_BLOCK_SIZE) * LETTER_CAPACITY - LETTER_BLOCK_SIZE)/2;

    float retVal = 0 - self.size.width/2 + edgeBuffer + LETTER_BLOCK_SIZE/2 + index * (LETTER_BLOCK_SIZE + slotMargin);
    return retVal;
}

# pragma mark - Adding and Removing Letters

- (void) addLetterToSection:(NSNotification*)notification
{
    //Get the letter from the notificaiton
    self.currentState = LetterSectionStateAddingLetter;
    NSString *letter = [[notification userInfo] objectForKey:KEY_GET_LETTER];
    LRLetterSlot *currentLetterSlot = nil;
    int letterCount = 0;
    for (LRLetterSlot* slot in self.letterSlots)
    {
        letterCount++;
        if ([slot isLetterSlotEmpty]) {
            currentLetterSlot = slot;
            break;
        }
    }
    //If all the letter slots are full
    if (currentLetterSlot) {
        currentLetterSlot.currentBlock = [LRLetterBlockGenerator createBlockForSlotWithLetter:letter];
    }
    [self updateSubmitButton];
    self.currentState = LetterSectionStateNormal;
}

- (void) removeLetterFromSection:(NSNotification*)notification
{
    self.currentState = LetterSectionStateRemovingLetter;
    LRLetterBlock *block = [[notification userInfo] objectForKey:KEY_GET_LETTER_BLOCK];
    LRLetterSlot *selectedSlot = nil;
    //Check to see if it's a child of the letter section
    __block BOOL foundNode = NO;
    [self enumerateChildNodesWithName:NAME_LETTER_BLOCK usingBlock:^(SKNode *node, BOOL *stop){
        if (node == block) {
            [node removeFromParent];
            foundNode = YES;
            return;
        }
    }];
    //Check to see if it exists within the letter slots
    for (int i = 0; i < self.letterSlots.count; i++)
    {
        LRLetterSlot *slot = [self.letterSlots objectAtIndex:i];
        //Get the slot chosen
        if ((!foundNode && slot.currentBlock == block) || (foundNode && [slot isLetterSlotEmpty] && !selectedSlot)) {
            selectedSlot = slot;
        }
        if (selectedSlot) {
            if (self.letterSlots.count - 1 > i) {
                slot.currentBlock = [(LRLetterSlot*)[self.letterSlots objectAtIndex:i+1] currentBlock];
            }
            else
                slot.currentBlock = [LRLetterBlockGenerator createEmptyLetterBlock];
        }

    }
    NSAssert(selectedSlot, @"Error: slot does not exist within array");
    [self updateSubmitButton];
    self.currentState = LetterSectionStateNormal;
}

#pragma mark - Submit Word Functions

- (void) submitWord
{
    self.currentState = LetterSectionStateSubmittingWord;
    [[LRScoreManager shared] submitWord:[self getCurrentWord:YES]];
    [self updateSubmitButton];
    self.currentState = LetterSectionStateNormal;
}

- (NSString*)getCurrentWord:(BOOL)popOffLetters
{
    NSMutableString *currentWord = [[NSMutableString alloc] init];
    for (LRLetterSlot *slot in self.letterSlots)
    {
        if ([slot isLetterSlotEmpty] || [slot.currentBlock isLetterBlockPlaceHolder])
            break;
        [currentWord appendString:[slot.currentBlock letter]];
        if (popOffLetters)
            slot.currentBlock = [LRLetterBlockGenerator createEmptyLetterBlock];
    }
    return currentWord;
}

- (void) updateSubmitButton
{
    int i;
    for (i = 0; i < self.letterSlots.count; i++)
    {
        if ([(LRLetterSlot*)[self.letterSlots objectAtIndex:i] isLetterSlotEmpty])
            break;
    }
    self.submitButton.playerCanSubmitWord = (i >= LETTER_MINIMUM_COUNT && [[LRDictionaryChecker shared] checkForWordInSet:[self getCurrentWord:NO]]);
}

#pragma mark - Reordering Functions
- (void) rearrangementScheduler:(NSNotification*)notification
{
    LRLetterBlock *block = [[notification userInfo] objectForKey:@"block"];
    self.rearrangementTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(checkRearrangement:) userInfo:block repeats:YES];
}

- (void) finishRearrangement:(NSNotification*)notification {
    //Cancel the timer
    [self.rearrangementTimer invalidate];
    self.rearrangementTimer = nil;
    
    LRLetterSlot *newLocation = [self getPlaceHolderSlot];
    newLocation.currentBlock = [[notification userInfo] objectForKey:@"block"];
    self.currentSlot = nil;
}

- (void) checkRearrangement:(NSTimer*)timer
{
    LRLetterBlock *block = [timer userInfo];
    LRLetterSlot *nearBySlot = [self getClosestSlot:block];
    if (!self.currentSlot && ![self getPlaceHolderSlot]) {
        NSLog(@"New place holder slot");
        nearBySlot.currentBlock = [LRLetterBlockGenerator createPlaceHolderBlock];
        self.currentSlot = nearBySlot;
    }
    else if (![nearBySlot.currentBlock isLetterBlockPlaceHolder] && [self slotIsWithinRearrangementArea:nearBySlot]) {
        [self swapLetterAtSlot:self.currentSlot withLetterAtSlot:nearBySlot];
        self.currentSlot = nearBySlot;
        return;
    }
}

- (BOOL) slotIsWithinRearrangementArea:(LRLetterSlot*)slot
{
    for (int i = 0; i < self.letterSlots.count; i++) {
        if ([[self.letterSlots objectAtIndex:i] isLetterSlotEmpty])
            break;
        else if ([self.letterSlots objectAtIndex:i] == slot)
            return YES;
    }
    return NO;
}

- (void) moveBlockToClosestEmptySlot:(LRLetterBlock*)letterBlock
{
    BOOL lastSlotWasFull = FALSE;
    CGPoint letterBlockPosition = [letterBlock convertPoint:self.position toNode:self];
    LRLetterSlot *closestSlot;
    float currentDiff = MAXFLOAT;
    for (int i = 0; i < [self.letterSlots count]; i++)
    {
        LRLetterSlot *slot = [self.letterSlots objectAtIndex:i];
        //If the first slot is empty
        if ([slot isLetterSlotEmpty] && i == 0) {
            closestSlot = slot;
            break;
        }
        //If the current slot is full
        else if (![slot isLetterSlotEmpty]) {
            lastSlotWasFull = YES;
            continue;
        }
        float nextDiff = ABS(letterBlockPosition.x - slot.position.x);
        if (nextDiff < currentDiff && lastSlotWasFull) {
            currentDiff = nextDiff;
            closestSlot = slot;
        }
        lastSlotWasFull = NO;
        
    }
    [closestSlot setCurrentBlock:letterBlock];
}

- (void) swapLetterAtSlot:(LRLetterSlot*) slotA withLetterAtSlot:(LRLetterSlot*) slotB
{
    int aLoc = 0;
    int bLoc = 0;
    for (int i = 0; i < self.letterSlots.count; i++)
    {
        LRLetterSlot *tempSlot = [self.letterSlots objectAtIndex:i];
        if (tempSlot == slotA)
            aLoc = i;
        else if (tempSlot == slotB)
            bLoc = i;
    }
    NSLog(@"Swapping block %i with block %i", aLoc, bLoc);
    
    LRLetterBlock *blockA = [slotA currentBlock];
    LRLetterBlock *blockB = [slotB currentBlock];

    NSAssert(!([blockA isLetterBlockEmpty] || [blockB isLetterBlockEmpty]), @"ERROR: cannot swap empty blocks");
    [slotA setCurrentBlock:blockB];
    [slotB setCurrentBlock:blockA];
}

- (LRLetterSlot*) getPlaceHolderSlot
{
    LRLetterSlot *retVal = nil;
    for (int i = 0; i < self.letterSlots.count; i++) {
        LRLetterSlot *tempSlot = [self.letterSlots objectAtIndex:i];
        if ([[tempSlot currentBlock] isLetterBlockPlaceHolder]) {
            NSAssert(!retVal, @"Error: multiple place holder slots");
            retVal = tempSlot;
        }
    }
    return retVal;
}

- (LRLetterSlot*)getClosestSlot:(LRLetterBlock*)letterBlock
{
    CGPoint letterBlockPosition = [letterBlock convertPoint:self.position toNode:self];
    LRLetterSlot *closestSlot;
    float currentDiff = MAXFLOAT;
    int location;
    for (int i = 0; i < [self.letterSlots count]; i++)
    {
        LRLetterSlot *slot = [self.letterSlots objectAtIndex:i];
        float nextDiff = ABS(letterBlockPosition.x - slot.position.x);
        if (nextDiff < currentDiff) {
            currentDiff = nextDiff;
            closestSlot = slot;
            location = i;
        }
    }
    //NSLog(@"Closest slot at index: %i", location);
    return closestSlot;
}

- (void) moveBlockAtSlotIndex:(int)i inDirection:(HorDirection)direction
{
    LRLetterSlot *currentSlot = [self.letterSlots objectAtIndex:i];
    LRLetterSlot *nextSlot = (direction == HorDirectionLeft) ? [self.letterSlots objectAtIndex:i-1] : [self.letterSlots objectAtIndex:i+1];
    LRLetterBlock *currentBlock = [currentSlot currentBlock];
    [nextSlot setCurrentBlock:currentBlock];
}

#pragma mark - Helper Functions

- (int) numLettersInSection
{
    for (int i = 0; i < self.letterSlots.count; i++)
    {
        if ([[self.letterSlots objectAtIndex:i] isLetterSlotEmpty])
            return i;
    }
    return (int)self.letterSlots.count;
}

@end
