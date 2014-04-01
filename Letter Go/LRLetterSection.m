//
//  LRLetterSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSection.h"
#import "LRLetterSlot.h"
#import "LRPositionConstants.h"
#import "LRLetterBlockGenerator.h"
#import "LRSubmitButton.h"
#import "LRScoreManager.h"
#import "LRDictionaryChecker.h"
#import "LRGameScene.h"
#import "LREnvelopeAnimationBuilder.h"
#import "LRCollisionManager.h"
#import "LRGameStateManager.h"
#import "LRColor.h"

typedef NS_ENUM(NSUInteger, LetterSectionState)
{
    LetterSectionStateNormal = 0,
    LetterSectionStateDeletingLetters,
    LetterSectionStateSubmittingWord
};

typedef void(^CompletionBlockType)(void);

@interface LRLetterSection ()

@property (nonatomic) BOOL gameOverFinished;
@property (nonatomic, strong) SKSpriteNode *letterSection;
@property (nonatomic, weak) LRSubmitButton *submitButton;
@property (nonatomic, strong) NSMutableArray *letterSlots;
@property (nonatomic, strong) NSMutableArray *delayedLetters;

@property (nonatomic, strong) SKSpriteNode *bottomBarrier;

@property (nonatomic, weak) LRLetterSlot  *currentSlot;
@property (nonatomic, weak) LRCollectedEnvelope *touchedBlock;

@property LetterSectionState letterSectionState;

@end

@implementation LRLetterSection
@synthesize bottomBarrier;

#pragma mark - Set Up/Initialization -

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        [self setUpNotifications];
    }
    return self;
}

- (void)setUpNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitWord:) name:NOTIFICATION_SUBMIT_WORD object:nil];
}

- (void)createSectionContent
{
    [self addChild:self.letterSection];    
    for (LRLetterSlot *slot in self.letterSlots) {
        [self addChild:slot];
    }
}

#pragma mark - Private Properties -

- (SKSpriteNode *)letterSection {
    if (!_letterSection) {
        _letterSection = [SKSpriteNode spriteNodeWithColor:[LRColor letterSectionColor] size:self.size];
//        _letterSection = [SKSpriteNode spriteNodeWithImageNamed:@"letterSection-background"];
//        _letterSection.size = self.size;
    }
    return _letterSection;
}

- (LRSubmitButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [[[[[LRGameStateManager shared] gameScene] gamePlayLayer] buttonSection] submitButton];
    }
    return _submitButton;
}

- (NSMutableArray *)letterSlots {
    if (!_letterSlots) {
        _letterSlots = [NSMutableArray new];
        
        //Fill the letter slot array with LRSlots
        for (int i = 0; i < kWordMaximumLetterCount; i++) {
            LRLetterSlot *slot = [LRLetterSlot new];
            slot.position = CGPointMake([self xPositionForSlotIndex:i], 0.0);
            slot.index = i;
            [_letterSlots addObject:slot];
        }
    }
    return _letterSlots;
}

- (NSMutableArray *)delayedLetters {
    if (!_delayedLetters) {
        _delayedLetters = [NSMutableArray new];
    }
    return _delayedLetters;
}

#pragma mark - LRLetterBlockControlDelegate Methods -
#pragma mark Addition
- (void)addEnvelopeToLetterSection:(id)envelope
{
    //If letters are being deleted currently, add them when they're done being deleted
    if (self.letterSectionState != LetterSectionStateNormal) {
        [self.delayedLetters addObject:envelope];
        return;
    }
    
    LRMovingEnvelope *newEnvelope = (LRMovingEnvelope *)envelope;
    NSString *letter = newEnvelope.letter;
    BOOL isLoveLetter = newEnvelope.loveLetter;

    LRLetterSlot *currentLetterSlot = nil;
    for (LRLetterSlot* slot in self.letterSlots)
    {
        //If the slot is empty
        if ([slot isLetterSlotEmpty]){
            currentLetterSlot = slot;
            break;
        }
        //If the last block is a place holder and the player is selecting a block
        else if (slot.index == ([self numLettersInSection] - 1)
                 && [slot.currentBlock isLetterBlockPlaceHolder])
        {
            LRLetterSlot *letterSlot = [self.letterSlots objectAtIndex:[self numLettersInSection]];
            letterSlot.currentBlock = [LRLetterBlockGenerator createPlaceHolderBlock];
            self.currentSlot = letterSlot;
            currentLetterSlot = slot;
            break;
        }
    }
    //If all the letter slots are not full
    if (currentLetterSlot) {
        LRCollectedEnvelope *block = [LRLetterBlockGenerator createBlockWithLetter:letter loveLetter:isLoveLetter];
        //Hide the block to make a fake one to run the animation with
        block.hidden = YES;
        block.delegate = self;
        currentLetterSlot.currentBlock = block;
        [self runAddLetterAnimationWithEnvelope:block];

    }
    [self _updateSubmitButton];
}

- (void)runAddLetterAnimationWithEnvelope:(LRCollectedEnvelope *)origEnvelope
{
    LRCollectedEnvelope *animatedEnvelope = [origEnvelope copy];
    animatedEnvelope.name = kTempCollectedEnvelopeName;
    animatedEnvelope.hidden = NO;
    
    CGPoint letterDropPos = origEnvelope.position;
    letterDropPos.y -= kCollectedEnvelopeSpriteDimension;
    animatedEnvelope.position = letterDropPos;
    SKAction *addEnvelopeAction = [LREnvelopeAnimationBuilder addLetterAnimation];
    SKAction *addLetterWithCompletion = [LREnvelopeAnimationBuilder actionWithCompletionBlock:addEnvelopeAction block:^{
        //...remove it after the max bounce count
        origEnvelope.hidden = NO;
        [animatedEnvelope removeFromParent];
    }];

    

    LRLetterSlot *parentSlot = self.letterSlots[origEnvelope.slotIndex];
    [parentSlot addChild:animatedEnvelope];
    [animatedEnvelope runAction:addLetterWithCompletion withKey:kAddLetterAnimationName];

}

#pragma mark Deletion
- (void)removeEnvelopeFromLetterSection:(id)envelope
{
    //Shift down all the letters in the letter section
    LRCollectedEnvelope *envelopeToDelete = (LRCollectedEnvelope *)envelope;
    NSUInteger deletionIndex = self.currentSlot.index;
    LRLetterSlot *deletionSlot = [self.letterSlots objectAtIndex:deletionIndex];
    deletionSlot.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
    
    self.currentSlot = nil;
    self.touchedBlock = nil;

    [self _shiftNonDeletedEnvelopesFromIndex:deletionIndex];
    [envelopeToDelete removeFromParent];
}

- (void)_shiftNonDeletedEnvelopesFromIndex:(NSUInteger)deletionIndex
{
    for (NSInteger i = deletionIndex; i < self.letterSlots.count; i++)
    {
        //Get the proper slot to update
        LRLetterSlot *slotToUpdate = [self.letterSlots objectAtIndex:i];
        SKAction *shiftAnimation = [LREnvelopeAnimationBuilder deletionAnimationWithDelayForIndex:i - deletionIndex];
        //Make sure all the envelopes have stopoped their animations
        [slotToUpdate stopEnvelopeChildAnimation];
        
        //And make a copy of the envelope to do the animation with
        LRCollectedEnvelope *slidingEnvelope = [slotToUpdate.currentBlock copy];
        slidingEnvelope.position = slotToUpdate.currentBlock.position;
        slidingEnvelope.name = kTempCollectedEnvelopeName;
        [slotToUpdate addChild:slidingEnvelope];
        
        //Run the animation on the fake slots
        CompletionBlockType shiftDone;
        if (i != self.letterSlots.count - 1)
        {
            [slidingEnvelope runAction:shiftAnimation];
        }
        else
        {
            //When the action is done, reveal the shifted letters
            shiftDone = ^{[self _revealShiftedLetters];};
            SKAction *shift = [LREnvelopeAnimationBuilder actionWithCompletionBlock:shiftAnimation
                                                                              block:shiftDone];
            [slidingEnvelope runAction: shift];
        }
    }
    //And just as soon as the action starts, do the real shifting of the letters
    [self _shiftLetterDataStructuresFromIndex:deletionIndex];
}

- (void)_shiftLetterDataStructuresFromIndex:(NSInteger)deletionIndex
{
    for (NSInteger k = deletionIndex; k < kWordMaximumLetterCount; k++)
    {
        LRLetterSlot *updatedSlot = self.letterSlots[k];
        //If it's the last slot, make it an empty block. Otherwise, make it the next block over
        LRCollectedEnvelope *newEnvelope = (k == kWordMaximumLetterCount - 1) ? [LRLetterBlockGenerator createEmptySectionBlock] :  [self.letterSlots[k + 1] currentBlock];
        newEnvelope.hidden = YES;
        updatedSlot.currentBlock = newEnvelope;
    }
}

- (void)_revealShiftedLetters
{
    int letterSlotCount = kWordMaximumLetterCount;
    for (int k = 0; k < letterSlotCount; k++)
    {
        LRLetterSlot *updatedSlot = self.letterSlots[k];
        updatedSlot.currentBlock.hidden = NO;
        [updatedSlot enumerateChildNodesWithName: kTempCollectedEnvelopeName usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
        }];
    }
    
    self.letterSectionState = LetterSectionStateNormal;
    [self _addDelayedLetters];
    [self _updateSubmitButton];
}

- (void)_addDelayedLetters
{
    for (id envelope in self.delayedLetters) {
        [self addEnvelopeToLetterSection:envelope];
    }
    [self.delayedLetters removeAllObjects];
}

#pragma mark Rearrangement
- (void)rearrangementHasBegunWithLetterBlock:(id)letterBlock
{
    self.touchedBlock = (LRCollectedEnvelope *)letterBlock;
    self.touchedBlock.zPosition = zPos_SectionBlock_Selected;
}

- (void)rearrangementHasFinishedWithLetterBlock:(id)letterBlock
{

    self.touchedBlock.zPosition = zPos_SectionBlock_Unselected;
    LRCollectedEnvelope *selectedEnvelope = (LRCollectedEnvelope *)letterBlock;
    
    LRLetterSlot *newLocation = [self getPlaceHolderSlot];
    [self runRearrangmentHasFinishedAnimationWithEnvelope:selectedEnvelope toSlot:newLocation];

    selectedEnvelope.hidden = YES;
    newLocation.currentBlock = (LRCollectedEnvelope *)letterBlock;

    self.currentSlot = nil;
    self.touchedBlock = nil;
    [self _updateSubmitButton];
}

- (void)runRearrangmentHasFinishedAnimationWithEnvelope:(LRCollectedEnvelope *)envelope toSlot:(LRLetterSlot *)destination
{
    LRCollectedEnvelope *animatedEnvelope = [envelope copy];
    animatedEnvelope.name = kTempCollectedEnvelopeName;

    CGPoint endPosition = destination.position;
    SKAction *slideAction = [LREnvelopeAnimationBuilder rearrangementFinishedAnimationFromPoint:animatedEnvelope.position toPoint:endPosition];
    SKAction *animationWithCompletion = [LREnvelopeAnimationBuilder actionWithCompletionBlock:slideAction block:^{
        [self removeChildrenInArray:@[animatedEnvelope]];
        destination.currentBlock.hidden = NO;
     }];
    [self addChild:animatedEnvelope];
    [animatedEnvelope runAction:animationWithCompletion];
}


#pragma mark Submit Word Functions

- (void)submitWord:(NSNotification *)notification
{
    NSString *forcedWord = [[notification userInfo] objectForKey:@"forcedWord"];
    NSString *submittedWord = (forcedWord) ? forcedWord : [self getCurrentWord];
    
    
    NSDictionary *wordDict = [NSDictionary dictionaryWithObjects:@[submittedWord, [self loveLetterIndices]] forKeys:@[@"word", @"loveLetters"]];
    NSInteger wordScore = [[LRScoreManager shared] submitWord:wordDict];
    if (!forcedWord)
    {
        LRHealthSection *healthSection = [[(LRGameScene *)[self scene] gamePlayLayer] healthSection];
        [healthSection addScore:wordScore];
        [self clearLetterSectionAnimated:YES];
    }
}


- (NSString *)getCurrentWord
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

- (NSSet *)loveLetterIndices
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

- (void)_updateSubmitButton
{
    int i;
    for (i = 0; i < self.letterSlots.count; i++)
    {
        if ([(LRLetterSlot *)[self.letterSlots objectAtIndex:i] isLetterSlotEmpty])
            break;
    }
    self.submitButton.isEnabled = (i >= kWordMinimumLetterCount && [[LRDictionaryChecker shared] checkForWordInDictionary:[self getCurrentWord]]);
}

#pragma mark - Reordering Functions -

- (void)update:(NSTimeInterval)currentTime
{
    if (self.touchedBlock) {
        [self checkRearrangement];
    }
}

- (void)checkRearrangement
{
    LRLetterSlot *nearBySlot = [self getClosestSlotToBlock:self.touchedBlock];
    
    //Is there not a place holder block?
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

- (BOOL) slotIsWithinRearrangementArea:(LRLetterSlot *)slot
{
    for (int i = 0; i < [self numLettersInSection]; i++) {
        if ([self.letterSlots objectAtIndex:i] == slot)
            return YES;
    }
    return NO;
}

#pragma mark Letter Swapping Functions

- (void)swapLetterAtSlot:(LRLetterSlot *)slotA withLetterAtSlot:(LRLetterSlot *)slotB
{
    NSLog(@"Swapping %@ and %@", slotA.currentBlock.letter, slotB.currentBlock.letter);
    //Get the location of the letter blocks with in the slot array
    [slotA stopEnvelopeChildAnimation];
    [slotB stopEnvelopeChildAnimation];
    
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

- (void)swapBlocksAtIndexA:(int)a indexB:(int)b
{
    LRLetterSlot *slotA = [self.letterSlots objectAtIndex:a];
    LRLetterSlot *slotB = [self.letterSlots objectAtIndex:b];
    
    LRCollectedEnvelope *blockA = [slotA currentBlock];
    LRCollectedEnvelope *blockB = [slotB currentBlock];
    LRCollectedEnvelope *nonEmptyEnvelope = [blockA isLetterBlockPlaceHolder] ? blockB : blockA;
    LRCollectedEnvelope *emptyEnvelope = [blockA isLetterBlockPlaceHolder] ? blockA : blockB;
    
    //Run the letter swapping animation
    SKAction *rearrangeAnimation = [LREnvelopeAnimationBuilder rearrangementLetterShiftedSlotsFromPoint:nonEmptyEnvelope.parent.position toPoint:emptyEnvelope.parent.position];
    LRCollectedEnvelope *animatedEnvelope = [nonEmptyEnvelope copy];
    animatedEnvelope.position = nonEmptyEnvelope.parent.position;
    [self addChild:animatedEnvelope];
    [animatedEnvelope runAction:rearrangeAnimation completion:^{
        [self removeChildrenInArray:@[animatedEnvelope]];
        nonEmptyEnvelope.hidden = NO;
    }];
    
    nonEmptyEnvelope.hidden = YES;
    
    [slotA setCurrentBlock:blockB];
    [slotB setCurrentBlock:blockA];
}

- (LRLetterSlot *)getPlaceHolderSlot
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
- (LRLetterSlot *)getClosestSlotToBlock:(LRCollectedEnvelope *)letterBlock
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

- (void)clearLetterSectionAnimated:(BOOL)animated
{
    self.letterSectionState  = LetterSectionStateSubmittingWord;
    for (int i = 0; i < [self.letterSlots count]; i++)
    {
        LRLetterSlot *slot = [self.letterSlots objectAtIndex:i];
    
        CompletionBlockType complete = ^{
            slot.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
            if (i == 0) {
                [self _updateSubmitButton];
                self.letterSectionState = LetterSectionStateNormal;
                [self _addDelayedLetters];
            }
        };
        if (animated) {
            SKAction *deletionAnimation = [LREnvelopeAnimationBuilder submitWordActionWithLetterAtIndex:i];
            SKAction *deletionAction = [LREnvelopeAnimationBuilder actionWithCompletionBlock:deletionAnimation
                                                                                       block:complete];
            [slot.currentBlock runAction:deletionAction];
        }
        else {
            complete();
        }
    }
}

- (CGFloat) xPositionForSlotIndex:(int) index {
    CGFloat rightOffset = kCollectedEnvelopeSpriteDimension/2;
    CGFloat leftOffset = -self.size.width/2;
    CGFloat retVal = index * kDistanceBetweenSlots + leftOffset + rightOffset;
    return retVal;
}

/*! Returns the numbers of letters in the letter section, including placeholder blocks */
- (int) numLettersInSection
{
    int count = 0;
    for (LRLetterSlot *slot in self.letterSlots) {
        if (![[slot currentBlock] isLetterBlockEmpty])
            count++;
    }
    return count;
}


- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    for (LRLetterSlot *slot in self.letterSlots) {
        slot.userInteractionEnabled = userInteractionEnabled;
        slot.currentBlock.userInteractionEnabled = userInteractionEnabled;
    }
}

#pragma mark - LRGameStateDelegate Methods
- (void)gameStateGameOver
{
    if (self.touchedBlock)
        [self.touchedBlock touchesEnded:nil withEvent:nil];
    self.gameOverFinished = TRUE;
    self.userInteractionEnabled = NO;
}

- (void)gameStateNewGame
{
    [self clearLetterSectionAnimated:NO];
    [self _removeAllEnvelopes];
    self.userInteractionEnabled = YES;
}

- (void)gameStatePaused:(NSTimeInterval)currentTime
{
    self.userInteractionEnabled = NO;
}

- (void)gameStateUnpaused:(NSTimeInterval)currentTime
{
    self.userInteractionEnabled = YES;
}

- (void)_removeAllEnvelopes
{
    if (self.touchedBlock)
    {
        [self removeChildrenInArray:@[self.touchedBlock]];
        self.touchedBlock = nil;
    }
}

//Debug function
/*
- (void)setCurrentSlot:(LRLetterSlot *)currentSlot
{
    [[self currentSlot] setColor:[UIColor whiteColor]];
    _currentSlot = currentSlot;
    currentSlot.color = [UIColor redColor];
}
*/
@end
