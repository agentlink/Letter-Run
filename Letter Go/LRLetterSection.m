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

@interface LRLetterSection ()

@property (nonatomic, strong) SKSpriteNode *letterSection;
@property (nonatomic, strong) LRSubmitButton *submitButton;
@property (nonatomic, strong) NSMutableArray *letterSlots;

@property (nonatomic) LRLetterSlot  *currentSlot;
@property LRCollectedEnvelope *touchedBlock;

@end

@implementation LRLetterSection

#pragma mark - Set Up/Initialization

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitWord:) name:NOTIFICATION_SUBMIT_WORD object:nil];
}

- (void) createSectionContent
{
    [self addChild:self.letterSection];
    [self addChild:self.submitButton];
    
    for (LRLetterSlot *slot in self.letterSlots) {
        [self addChild:slot];
    }
    
    [self addVerticalBarriers];
}

/*!
 Add sprites above and below the letter slots so vertical scroll
 deletion goes behind the letter section but horizontal scroll
 rearrangement does not.
 */
- (void) addVerticalBarriers
{
    SKSpriteNode *topBarrier, *bottomBarrier;
    
    CGFloat barrierHeight = (self.frame.size.height - kLetterBlockDimension) / 2;
    CGFloat barrierWidth = self.size.width;
    CGSize barrierSize = CGSizeMake(barrierWidth, barrierHeight);
    
    CGFloat barrierXPos = self.position.x;
    CGFloat bottomBarrierYPos = self.frame.origin.y + barrierHeight/2;
    CGFloat topBarrierYPos = bottomBarrierYPos + barrierHeight + kLetterBlockDimension;
    
    bottomBarrier = [SKSpriteNode spriteNodeWithColor:[LRColor letterSectionColor]
                                                 size:barrierSize];
    bottomBarrier.position = CGPointMake(barrierXPos, bottomBarrierYPos);
    bottomBarrier.zPosition = zPos_LetterSectionBarrier;
    [self addChild:bottomBarrier];
    
    topBarrier = [SKSpriteNode spriteNodeWithColor:[LRColor letterSectionColor]
                                              size:barrierSize];
    topBarrier.position = CGPointMake(barrierXPos, topBarrierYPos);
    topBarrier.zPosition = zPos_LetterSectionBarrier;
    [self addChild:topBarrier];
    
}

#pragma mark - Private Properties

- (SKSpriteNode*) letterSection {
    if (!_letterSection) {
        _letterSection = [SKSpriteNode spriteNodeWithColor:[LRColor letterSectionColor] size:self.size];
    }
    return _letterSection;
}

- (LRSubmitButton*) submitButton {
    if (!_submitButton) {
        _submitButton = [LRSubmitButton new];
        _submitButton.position = CGPointMake([self xPosFromSlotIndex:kWordMaximumLetterCount], 0);
    }
    return _submitButton;
}

- (NSMutableArray*) letterSlots {
    if (!_letterSlots) {
        _letterSlots = [NSMutableArray new];
        
        //Fill the letter slot array with LRSlots
        for (int i = 0; i < kWordMaximumLetterCount; i++) {
            LRLetterSlot *slot = [LRLetterSlot new];
            slot.position = CGPointMake([self xPosFromSlotIndex:i], 0.0);
            [_letterSlots addObject:slot];
        }
    }
    return _letterSlots;
}

#pragma mark - LRLetterBlockControlDelegate Methods
#pragma mark Addition/Deletion
- (void) addEnvelopeToLetterSection:(id)envelope
{
    LRMovingBlock *newEnvelope = (LRMovingBlock*)envelope;
    NSString *letter = newEnvelope.letter;
    BOOL isLoveLetter = newEnvelope.loveLetter;

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
        LRCollectedEnvelope *block = [LRLetterBlockGenerator createBlockWithLetter:letter loveLetter:isLoveLetter];
        block.delegate = self;
        currentLetterSlot.currentBlock = block;
    }
    [self updateSubmitButton];
}

- (void) removeEnvelopeFromLetterSection:(id)envelope
{
    LRCollectedEnvelope *block = (LRCollectedEnvelope*)envelope;
    LRLetterSlot *selectedSlot = nil;

    //Check to see if it exists within the letter slots
    for (int i = 0; i < self.letterSlots.count; i++)
    {
        LRLetterSlot *slot = [self.letterSlots objectAtIndex:i];
        //If the slot his holding the deleted block
        if (slot.currentBlock == block) {
            selectedSlot = slot;
        }
        if (selectedSlot) {
            //If it's not the last block
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

#pragma mark Rearrangement
- (void) rearrangementHasBegunWithLetterBlock:(id)letterBlock
{
    self.touchedBlock = (LRCollectedEnvelope*)letterBlock;
}

- (void) rearrangementHasFinishedWithLetterBlock:(id)letterBlock
{
    LRLetterSlot *newLocation = [self getPlaceHolderSlot];
    newLocation.currentBlock = (LRCollectedEnvelope*)letterBlock;
    self.currentSlot = nil;
    self.touchedBlock = nil;
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
        LRHealthSection *healthSection = [[(LRGameScene*)[self scene] gamePlayLayer] healthSection];
        [healthSection addScore:wordScore];
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
    self.submitButton.userInteractionEnabled = (i >= kWordMinimumLetterCount && [[LRDictionaryChecker shared] checkForWordInDictionary:[self getCurrentWord]]);
}

#pragma mark - Reordering Functions -

- (void) update:(NSTimeInterval)currentTime
{
    if (self.touchedBlock) {
        [self checkRearrangement];
    }
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

#pragma mark Letter Swapping Functions

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
    
    LRCollectedEnvelope *blockA = [slotA currentBlock];
    LRCollectedEnvelope *blockB = [slotB currentBlock];
    
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
- (LRLetterSlot*)getClosestSlotToBlock:(LRCollectedEnvelope*)letterBlock
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

- (void) clearLetterSection
{
    for (LRLetterSlot *slot in self.letterSlots) {
        slot.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
    }
    [self updateSubmitButton];
}

- (CGFloat) xPosFromSlotIndex:(int) index {
    float slotMargin, edgeBuffer;
    slotMargin = (IS_IPHONE_5) ? kLetterBlockDimension/3.3 : kLetterBlockDimension/4;
    edgeBuffer = (self.size.width - (slotMargin + kLetterBlockDimension) * kWordMaximumLetterCount - kLetterBlockDimension)/2;
    
    float retVal = 0 - self.size.width/2 + edgeBuffer + kLetterBlockDimension/2 + index * (kLetterBlockDimension + slotMargin);
    return retVal;
}

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
