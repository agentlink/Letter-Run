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

@end

@implementation LRLetterSection

#pragma mark - Set Up

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLetterToSection:) name:NOTIFICATION_ADDED_LETTER object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLetterFromSection:) name:NOTIFICATION_DELETE_LETTER object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitWord) name:NOTIFICATION_SUBMIT_WORD object:nil];
    }
    return self;
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
}

- (void) removeLetterFromSection:(NSNotification*)notification
{
    LRLetterBlock *block = [[notification userInfo] objectForKey:KEY_GET_LETTER_BLOCK];
    LRLetterSlot *selectedSlot = nil;
    for (int i = 0; i < self.letterSlots.count; i++)
    {
        LRLetterSlot *slot = [self.letterSlots objectAtIndex:i];
        //Get the slot chosen
        if (slot.currentBlock == block) {
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
    [self updateSubmitButton];
    NSAssert(selectedSlot, @"Error: slot does not exist within array");
}

#pragma mark - Submit Word Functions

- (void) submitWord
{
    [[LRScoreManager shared] submitWord:[self getCurrentWord:YES]];
    [self updateSubmitButton];
}

- (NSString*)getCurrentWord:(BOOL)popOffLetters
{
    NSMutableString *currentWord = [[NSMutableString alloc] init];
    for (LRLetterSlot *slot in self.letterSlots)
    {
        if ([slot isLetterSlotEmpty])
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
- (void) moveBlockToClosestToBlock:(LRLetterBlock*)letterBlock
{
    CGPoint letterBlockPosition = [letterBlock convertPoint:self.position toNode:self];
    LRLetterSlot *closestSlot;
    float currentDiff = MAXFLOAT;
    for (LRLetterSlot *slot in self.letterSlots)
    {
        float nextDiff = ABS(letterBlockPosition.x - slot.position.x);
        if (nextDiff < currentDiff) {
            currentDiff = nextDiff;
            closestSlot = slot;
        }
    }
    [closestSlot setCurrentBlock:letterBlock];
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
