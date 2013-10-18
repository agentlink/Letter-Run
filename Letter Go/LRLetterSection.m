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
#import "LRGameScene.h"

#define LETTER_MINIMUM_COUNT        3

//UICollectionView
//868-Hack

@interface LRLetterSection ()

@property SKSpriteNode *letterSection;
@property LRSubmitButton *submitButton;
@property NSMutableArray *letterSlots;

@property LRLetterSlot *currentSlot;
@property LRSectionBlock *touchedBlock;

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

# pragma mark - Game State Functions

- (void) clearLetterSection
{
    for (LRLetterSlot *slot in self.letterSlots) {
        slot.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
    }
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
        currentLetterSlot.currentBlock = [LRLetterBlockGenerator createBlockWithLetter:letter];
    }
    [self updateSubmitButton];
    self.currentState = LetterSectionStateNormal;
}

- (void) removeLetterFromSection:(NSNotification*)notification
{
    self.currentState = LetterSectionStateRemovingLetter;
    LRSectionBlock *block = [[notification userInfo] objectForKey:KEY_GET_LETTER_BLOCK];
    LRLetterSlot *selectedSlot = nil;
    //Check to see if it's a child of the letter section
    __block BOOL foundNode = NO;
    [self enumerateChildNodesWithName:NAME_SPRITE_SECTION_LETTER_BLOCK usingBlock:^(SKNode *node, BOOL *stop){
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
                slot.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
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
    NSString *currentWord = [self getCurrentWord:YES];
    [[LRScoreManager shared] submitWord:currentWord];
    [[[(LRGameScene*)[self scene] gamePlayLayer] healthSection] submitWord:currentWord];
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
            slot.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
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
    self.submitButton.playerCanSubmitWord = (i >= LETTER_MINIMUM_COUNT && [[LRDictionaryChecker shared] checkForWordInDictionary:[self getCurrentWord:NO]]);
}

#pragma mark - Reordering Functions
- (void) update:(NSTimeInterval)currentTime
{
    if (self.touchedBlock) {
        [self checkRearrangement];
    }
}
- (void) rearrangementScheduler:(NSNotification*)notification
{
    self.touchedBlock = [[notification userInfo] objectForKey:@"block"];
}

- (void) finishRearrangement:(NSNotification*)notification {

    LRLetterSlot *newLocation = [self getPlaceHolderSlot];
    newLocation.currentBlock = [[notification userInfo] objectForKey:@"block"];
    self.currentSlot = nil;
    self.touchedBlock = nil;
    [self updateSubmitButton];
}

- (void) checkRearrangement
{
    LRLetterSlot *nearBySlot = [self getClosestSlot:self.touchedBlock];
    if (!self.currentSlot && ![self getPlaceHolderSlot]) {
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
    if (ABS(aLoc - bLoc) > 1)
        NSLog(@"Warning: swapping with non-contiguous block.");
    LRSectionBlock *blockA = [slotA currentBlock];
    LRSectionBlock *blockB = [slotB currentBlock];

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

- (LRLetterSlot*)getClosestSlot:(LRSectionBlock*)letterBlock
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
    return closestSlot;
}

- (void) moveBlockAtSlotIndex:(int)i inDirection:(HorDirection)direction
{
    LRLetterSlot *currentSlot = [self.letterSlots objectAtIndex:i];
    LRLetterSlot *nextSlot = (direction == HorDirectionLeft) ? [self.letterSlots objectAtIndex:i-1] : [self.letterSlots objectAtIndex:i+1];
    LRSectionBlock *currentBlock = [currentSlot currentBlock];
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
