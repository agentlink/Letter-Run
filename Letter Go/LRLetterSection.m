//
//  LRLetterSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSection.h"
#import "LRLetterSlot.h"

#import "LRLetterBlockGenerator.h"
#import "LRSubmitButton.h"
#import "LRScoreManager.h"
#import "LRDictionaryChecker.h"
#import "LRGameScene.h"

//UICollectionView
//868-Hack

@interface LRLetterSection ()

@property SKSpriteNode *letterSection;
@property LRSubmitButton *submitButton;
@property NSMutableArray *letterSlots;

@property (nonatomic) LRLetterSlot  *currentSlot;
@property LRSectionBlock *touchedBlock;

@end

@implementation LRLetterSection
#pragma mark - Set Up

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        [self setUpNotifications];
    }
    return self;
}

- (void) setUpNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLetterToSection:) name:NOTIFICATION_ADDED_LETTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLetterFromSection:) name:NOTIFICATION_DELETE_LETTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitWord:) name:NOTIFICATION_SUBMIT_WORD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rearrangementScheduler:) name:NOTIFICATION_REARRANGE_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRearrangement:) name:NOTIFICATION_REARRANGE_FINISH object:nil];
}

# pragma mark - Game State Functions

- (void) clearLetterSection
{
    for (LRLetterSlot *slot in self.letterSlots) {
        slot.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
    }
    [self updateSubmitButton];
}

- (void) createSectionContent
{
    //The color will be replaced by a health bar sprite
    self.letterSection = [SKSpriteNode spriteNodeWithColor:[LRColor letterSectionColor] size:self.size];
    [self addChild:self.letterSection];
    self.letterSlots = [[NSMutableArray alloc] initWithCapacity:LETTER_CAPACITY];
    
    
    //Create the letter slots
    for (int i = 0; i < LETTER_CAPACITY; i++)
    {
        float yOffSet = 0;
        LRLetterSlot *slot = [[LRLetterSlot alloc] init];
        slot.position = CGPointMake([self xPosFromSlotIndex:i], yOffSet);
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
    slotMargin = (IS_IPHONE_5) ? SIZE_LETTER_BLOCK/3.3 : SIZE_LETTER_BLOCK/4;
    edgeBuffer = (self.size.width - (slotMargin + SIZE_LETTER_BLOCK) * LETTER_CAPACITY - SIZE_LETTER_BLOCK)/2;

    float retVal = 0 - self.size.width/2 + edgeBuffer + SIZE_LETTER_BLOCK/2 + index * (SIZE_LETTER_BLOCK + slotMargin);
    return retVal;
}

# pragma mark - Adding and Removing Letters

- (void) addLetterToSection:(NSNotification*)notification
{
    //Get the letter from the notificaiton
    NSString *letter = [[notification userInfo] objectForKey:KEY_GET_LETTER];
    BOOL isLoveLetter = [[[notification userInfo] objectForKey:KEY_GET_LOVE] boolValue];

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
    //If all the letter slots are not full
    if (currentLetterSlot) {
        currentLetterSlot.currentBlock = [LRLetterBlockGenerator createBlockWithLetter:letter loveLetter:isLoveLetter];
    }
    [self updateSubmitButton];
}

- (void) removeLetterFromSection:(NSNotification*)notification
{
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
}


#pragma mark - Submit Word Functions

- (void) submitWord:(NSNotification*)notification
{
    NSString *forcedWord = [[notification userInfo] objectForKey:@"forcedWord"];
    NSString *submittedWord = (forcedWord) ? forcedWord : [self getCurrentWord];
    
    
    NSDictionary *wordDict = [NSDictionary dictionaryWithObjects:@[submittedWord, [self loveLetterIndices]] forKeys:@[@"word", @"loveLetters"]];
    int wordScore = [[LRScoreManager shared] submitWord:wordDict];
    if (!forcedWord)
    {
        [[[(LRGameScene*)[self scene] gamePlayLayer] healthSection] addScore:wordScore];
        [self clearLetterSection];
    }
}


- (NSString*)getCurrentWord
{
    NSMutableString *currentWord = [[NSMutableString alloc] init];
    for (LRLetterSlot *slot in self.letterSlots)
    {
        if ([slot isLetterSlotEmpty] || [slot.currentBlock isLetterBlockPlaceHolder])
            break;
        [currentWord appendString:[slot.currentBlock letter]];
    }
    return currentWord;
}

- (NSSet*) loveLetterIndices
{
    NSMutableSet *indices = [NSMutableSet set];
    for (int i = 0; i < [self.letterSlots count]; i++) {
        LRLetterSlot *slot = [self.letterSlots objectAtIndex:i];
        if (![slot.currentBlock isLetterBlockEmpty] && [slot.currentBlock loveLetter]) {
            [indices addObject:[NSNumber numberWithInt:i]];
        }
    }
    return indices;
}

- (void) updateSubmitButton
{
    int i;
    for (i = 0; i < self.letterSlots.count; i++)
    {
        if ([(LRLetterSlot*)[self.letterSlots objectAtIndex:i] isLetterSlotEmpty])
            break;
    }
    self.submitButton.userInteractionEnabled = (i >= LETTER_MINIMUM_COUNT && [[LRDictionaryChecker shared] checkForWordInDictionary:[self getCurrentWord]]);
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
    LRLetterSlot *nearBySlot = [self getClosestSlotToBlock:self.touchedBlock];
    
    //Is there now a place holder block?
    if (!self.currentSlot && ![self getPlaceHolderSlot]) {
        nearBySlot.currentBlock = [LRLetterBlockGenerator createPlaceHolderBlock];
        self.currentSlot = nearBySlot;
    }
    //Check if the place holder is not in the proper place
    else if (![nearBySlot.currentBlock isLetterBlockPlaceHolder]) {
        //Make sure that either its new location or old location are within the rearrangement area
        [self swapLetterAtSlot:self.currentSlot withLetterAtSlot:nearBySlot];
        if ([self slotIsWithinRearrangementArea:nearBySlot]) {
            self.currentSlot = nearBySlot;
        }
        else
            self.currentSlot = [self.letterSlots objectAtIndex:[self numLettersInSection] - 1];
        return;
    }
}

- (BOOL) slotIsWithinRearrangementArea:(LRLetterSlot*)slot
{
    for (int i = 0; i < [self numLettersInSection]; i++) {
        if ([self.letterSlots objectAtIndex:i] == slot)
            return YES;
    }
    return NO;
}

- (void) swapLetterAtSlot:(LRLetterSlot*) slotA withLetterAtSlot:(LRLetterSlot*) slotB
{
    //Get the location of the letter blocks with in the slot array
    int aLoc = -1;
    int bLoc = -1;
    for (int i = 0; i < self.letterSlots.count; i++)
    {
        LRLetterSlot *tempSlot = [self.letterSlots objectAtIndex:i];
        if (tempSlot == slotA) {
            aLoc = i;
        }
        //If the block has been moved to the right, past edge of filled blocks
        else if (aLoc >= 0 && bLoc == -1 && [[tempSlot currentBlock] isLetterBlockEmpty]) {
            bLoc = i - 1;
            break;
        }
        else if (tempSlot == slotB) {
            bLoc = i;
        }
    }
    
    //Swap either to the left or right
    if (aLoc < bLoc) {
        for (int i = aLoc; i < bLoc; i++) {
            [self swapBlocksAtIndexA:i indexB:i+1];
        }
    }
    else if (aLoc > bLoc) {
        for (int i = aLoc; i > bLoc; i--) {
            [self swapBlocksAtIndexA:i indexB:i-1];
        }
    }
}

- (void) swapBlocksAtIndexA:(int)a indexB:(int)b
{
    LRLetterSlot *slotA = [self.letterSlots objectAtIndex:a];
    LRLetterSlot *slotB = [self.letterSlots objectAtIndex:b];
    
    LRSectionBlock *blockA = [slotA currentBlock];
    LRSectionBlock *blockB = [slotB currentBlock];
    
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

///Get the closest section block to a given position (provided by touch)
- (LRLetterSlot*)getClosestSlotToBlock:(LRSectionBlock*)letterBlock
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

#pragma mark - Helper Functions

- (int) numLettersInSection
{
    int count = 0;;
    for (LRLetterSlot *slot in self.letterSlots) {
        if (![[slot currentBlock] isLetterBlockEmpty])
            count++;
    }
    return count;
}


- (void) setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    for (LRLetterSlot *slot in self.letterSlots) {
        slot.userInteractionEnabled = userInteractionEnabled;
        slot.currentBlock.userInteractionEnabled = userInteractionEnabled;
    }
}

//Debug function
/*
- (void) setCurrentSlot:(LRLetterSlot *)currentSlot
{
    [[self currentSlot] setColor:[UIColor whiteColor]];
    _currentSlot = currentSlot;
    currentSlot.color = [UIColor redColor];
}
*/
@end
