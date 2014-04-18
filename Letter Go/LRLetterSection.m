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

//@property (nonatomic, weak) LRLetterSlot  *currentSlot;
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
    
    //Converting from a moving envelope to a collected envelope...
    LRMovingEnvelope *newEnvelope = (LRMovingEnvelope *)envelope;
    NSString *letter = newEnvelope.letter;

    LRLetterSlot *firstEmptySlot = [self _firstEmptySlot];
    if (firstEmptySlot) {
        LRCollectedEnvelope *block = [LRLetterBlockGenerator createBlockWithLetter:letter paperColor:newEnvelope.paperColor];
        //Hide the block to make a fake one to run the animation with
        block.hidden = YES;
        block.delegate = self;
        firstEmptySlot.currentBlock = block;
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
    NSAssert(envelope == self.touchedBlock, @"Only the touched block should be removed");
    NSAssert(![self _placeholderSlot], @"Should not be a placeholder slot if removing");

    LRCollectedEnvelope *envelopeToDelete = (LRCollectedEnvelope *)envelope;
    [envelopeToDelete removeFromParent];
    self.touchedBlock = nil;
}

- (void)_shiftLetterDataStructuresInRange:(NSRange)range direction:(LRDirection)direction
{
    //Make sure this works for both left and right. Maybe do something with changing the direciton using the new LRDirection values
    //TODO: Add assertsions
    
    /*
     
     If you are shifting to the right, start from left side and set each slot to the value of the envelope on its right
     If you are shifting to the left, start from the right side and set each slot to the value of the envelope on its left
     */
    NSInteger startVal = (direction == kLRDirectionRight) ? kWordMaximumLetterCount - 1: range.location - 1;
    NSInteger endVal = (direction == kLRDirectionRight) ? range.location : kWordMaximumLetterCount;
    
    for (int i = startVal; i != endVal; i += direction)
    {
        LRLetterSlot *newLocation = self.letterSlots[i];
        if (i == kWordMaximumLetterCount - 1 && direction == kLRDirectionLeft) {
            newLocation.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
        }
        else {
            LRLetterSlot *formerLocation = self.letterSlots[i + direction];
            newLocation.currentBlock = formerLocation.currentBlock;
        }
        newLocation.currentBlock.hidden = YES;
    }
    //If it's shifting to the right, put the placeholder at the slot closest to where the touched block is
    if (direction == kLRDirectionRight) {
        LRLetterSlot *placeholderSlot = self.letterSlots[endVal];
        placeholderSlot.currentBlock = [LRCollectedEnvelope placeholderCollectedEnvelope];
    }
    //If it's shifting to the left and there is a placeholder block at the end, get rid of it
    else if ([self _placeholderSlot].index == [self numLettersInSection] - 1 && direction == kLRDirectionLeft)
    {
        [self _placeholderSlot].currentBlock = [LRCollectedEnvelope emptyCollectedEnvelope];
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
    //TODO: Test if this call is now screwed up
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

- (void) setTouchedBlock:(LRCollectedEnvelope *)touchedBlock
{
    NSAssert(!(_touchedBlock && touchedBlock), @"Touched block should only be set if it is nil");
    _touchedBlock = touchedBlock;
}

#pragma mark Rearrangement
- (void)rearrangementHasBegunWithLetterBlock:(id)letterBlock
{
    self.touchedBlock = (LRCollectedEnvelope *)letterBlock;
    self.touchedBlock.zPosition = zPos_SectionBlock_Selected;
    
    NSAssert(![self _placeholderSlot], @"Should not be placeholder slot if rearrangement hasn't started yet");
    LRLetterSlot *newPlaceholderSlot = self.letterSlots[self.touchedBlock.slotIndex];
    newPlaceholderSlot.currentBlock = [LRCollectedEnvelope placeholderCollectedEnvelope];
}

- (void)rearrangementHasFinishedWithLetterBlock:(id)letterBlock
{
    NSAssert(letterBlock == self.touchedBlock, @"Rearrangment should only start and finish with touched block");
    LRCollectedEnvelope *selectedEnvelope = (LRCollectedEnvelope *)letterBlock;
    LRLetterSlot *newLocation = [self _placeholderSlot];
    [self runRearrangmentHasFinishedAnimationWithEnvelope:selectedEnvelope toSlot:newLocation];

    selectedEnvelope.hidden = YES;
    newLocation.currentBlock = (LRCollectedEnvelope *)letterBlock;

    self.touchedBlock = nil;
    [self _updateSubmitButton];
}

- (void)deletabilityHasChangedTo:(BOOL)deletable forLetterBlock:(id)letterBlock
{
    NSAssert(letterBlock == self.touchedBlock, @"Deletability should only change with touched block");
    LRCollectedEnvelope *collected = letterBlock;
    
    //Set the slot index to the nearest letter
    NSUInteger nearbySlotIndex = [self _closestSlotToBlock:collected].index;
    if (nearbySlotIndex >= [self numLettersInSection]) {
        nearbySlotIndex = [self _firstEmptySlot].index;
    }
    collected.slotIndex = nearbySlotIndex;
    
    NSUInteger firstBlockIndex = deletable ? collected.slotIndex + 1 : collected.slotIndex;
    NSUInteger length = [self numLettersInSection] - firstBlockIndex;
    LRDirection direction = deletable ? kLRDirectionLeft : kLRDirectionRight;
    NSRange letterRange = NSMakeRange(firstBlockIndex, length);
    [self _shiftEnvelopesInRange:letterRange direction:direction];    
}


- (void)_shiftEnvelopesInRange:(NSRange)slotRange direction:(LRDirection)direction
{
    //TODO: add other assertions here
    NSAssert(slotRange.length + slotRange.location <= kWordMaximumLetterCount, @"Shift envelope range exceeds max letter count");
    int endcount = kWordMaximumLetterCount;//slotRange.length + slotRange.location;
    int initialIndex = slotRange.location;
    LRLetterSlot *currentSlot;
    
    for (int i = initialIndex; i < endcount; i++)
    {
        //Build the animation based off of the relative slot
        currentSlot = self.letterSlots[i];
        //Stop the addition animation if it's happening
        [currentSlot stopEnvelopeChildAnimation];
        int relativeIndex = (direction == kLRDirectionLeft) ? i - initialIndex : endcount - i;
        SKAction *shiftAnimation = [LREnvelopeAnimationBuilder shiftLetterInDirection:direction withDelayForIndex:relativeIndex];
        
        //Create a copy of the envelope to run the animation on
        LRCollectedEnvelope *animatedEnvelope = [self _copyOfEnvelopeFromSlot:currentSlot];
        [currentSlot addChild:animatedEnvelope];
        CompletionBlockType shiftDone;
        //Reveal the real letters after the last block has shifted
        if (i == endcount - 1)
        {
            shiftDone = ^{[self _revealShiftedLetters];};
            SKAction *shift = [LREnvelopeAnimationBuilder actionWithCompletionBlock:shiftAnimation
                                                                              block:shiftDone];
            [animatedEnvelope runAction: shift];
        }
        else
        {
            [animatedEnvelope runAction:shiftAnimation];
        }
    }
    [self _shiftLetterDataStructuresInRange:slotRange direction:direction];

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

- (LRCollectedEnvelope *)_copyOfEnvelopeFromSlot:(LRLetterSlot *)slot
{
    NSParameterAssert(slot);
    LRCollectedEnvelope *envelope = [[slot currentBlock] copy];
    envelope.name = kTempCollectedEnvelopeName;
    envelope.position = slot.currentBlock.position;
    return envelope;
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
        if ([slot isLetterSlotEmpty] || [slot.currentBlock isCollectedEnvelopePlaceholder])
            break;
        [currentWord appendString:[slot.currentBlock letter]];
    }
    return currentWord;
}

- (NSSet *)loveLetterIndices
{
    return [NSSet set];
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
    if (self.touchedBlock && !self.touchedBlock.isAtDeletionPoint) {
        [self _checkRearrangement];
    }
}

- (void)_checkRearrangement
{
    LRLetterSlot *nearBySlot = [self _closestSlotToBlock:self.touchedBlock];
    LRLetterSlot *placeholderSlot = [self _placeholderSlot];
    NSAssert(placeholderSlot, @"Placeholder slot cannot be nil if rearranging");
    //If the current placeholder slot is not aligned with the location of the touched block
    if (nearBySlot != placeholderSlot)
    {
        if ([self _slotIsWithinRearrangementArea:nearBySlot]) {
            [self swapBlocksAtIndexA:nearBySlot.index indexB:placeholderSlot.index];
        }
    }
}

- (BOOL) _slotIsWithinRearrangementArea:(LRLetterSlot *)slot
{
    for (int i = 0; i < [self numLettersInSection]; i++) {
        if ([self.letterSlots objectAtIndex:i] == slot)
            return YES;
    }
    return NO;
}

#pragma mark Letter Swapping Functions
- (void)swapBlocksAtIndexA:(NSUInteger)a indexB:(NSUInteger)b
{
    LRLetterSlot *slotA = [self.letterSlots objectAtIndex:a];
    LRLetterSlot *slotB = [self.letterSlots objectAtIndex:b];
    [slotA stopEnvelopeChildAnimation];
    [slotB stopEnvelopeChildAnimation];
    
    LRCollectedEnvelope *blockA = [slotA currentBlock];
    LRCollectedEnvelope *blockB = [slotB currentBlock];
    LRCollectedEnvelope *nonEmptyEnvelope = [blockA isCollectedEnvelopePlaceholder] ? blockB : blockA;
    LRCollectedEnvelope *emptyEnvelope = [blockA isCollectedEnvelopePlaceholder] ? blockA : blockB;
    
    //Run the letter swapping animation
    SKAction *rearrangeAnimation = [LREnvelopeAnimationBuilder swapEnvelopeFromPoint:nonEmptyEnvelope.parent.position toPoint:emptyEnvelope.parent.position];
    LRCollectedEnvelope *animatedEnvelope = [self _copyOfEnvelopeFromSlot:self.letterSlots[nonEmptyEnvelope.slotIndex]];
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

- (LRLetterSlot *)_placeholderSlot
{
    LRLetterSlot *retVal = nil;
    for (int i = 0; i < self.letterSlots.count; i++) {
        LRLetterSlot *tempSlot = [self.letterSlots objectAtIndex:i];
        if ([[tempSlot currentBlock] isCollectedEnvelopePlaceholder]) {
            NSAssert(!retVal, @"Error: multiple place holder slots");
            retVal = tempSlot;
        }
    }
    return retVal;
}

- (LRLetterSlot *)_firstEmptySlot
{
    LRLetterSlot *empty = nil;
    for (LRLetterSlot* slot in self.letterSlots)
    {
        //If the slot is empty
        if ([slot isLetterSlotEmpty]){
            empty = slot;
            break;
        }
    }
    return empty;
}

///Get the closest section block to a given position (provided by touch)
- (LRLetterSlot *)_closestSlotToBlock:(LRCollectedEnvelope *)letterBlock
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
        if (![[slot currentBlock] isCollectedEnvelopeEmpty])
            count++;
    }
    return count;
}

#pragma mark - LRGameStateDelegate Methods
- (void)gameStateGameOver
{
    if (self.touchedBlock) {
        [self.touchedBlock touchesEnded:nil withEvent:nil];
        self.touchedBlock.userInteractionEnabled = NO;
    }
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

@end
