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

typedef NS_ENUM(NSUInteger, LetterSectionState)
{
    LetterSectionStateNormal = 0,
    LetterSectionStateDeletingLetters,
    LetterSectionStateSubmittingWord
};

typedef void(^CompletionBlockType)(void);

@interface LRLetterSection ()

@property (nonatomic, strong) SKSpriteNode *letterSection;
@property (nonatomic, strong) LRSubmitButton *submitButton;
@property (nonatomic, strong) NSMutableArray *letterSlots;
@property (nonatomic, strong) NSMutableArray *delayedLetters;

@property (nonatomic, strong) SKSpriteNode *bottomBarrier;

@property (nonatomic) LRLetterSlot  *currentSlot;
@property LRCollectedEnvelope *touchedBlock;

@property LetterSectionState letterSectionState;

@end

@implementation LRLetterSection
@synthesize bottomBarrier;

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
    
    [self addBarriers];
}

/*!
 Add sprites above and below the letter slots so vertical scroll
 deletion goes behind the letter section but horizontal scroll
 rearrangement does not.
 */

- (void) addBarriers
{
    [self addVerticalBarriers];
    [self addHorizontalBarriers];
}

- (void) addVerticalBarriers
{
    SKSpriteNode *topBarrier;
    
    CGFloat barrierHeight = (self.frame.size.height - kLetterBlockDimension) / 2;
    CGFloat barrierWidth = self.size.width;
    CGSize barrierSize = CGSizeMake(barrierWidth, barrierHeight);
    
    CGFloat barrierXPos = self.position.x;
    CGFloat bottomBarrierYPos = self.frame.origin.y + barrierHeight/2;
    CGFloat topBarrierYPos = bottomBarrierYPos + barrierHeight + kLetterBlockDimension;
    
    bottomBarrier = [SKSpriteNode spriteNodeWithColor:[LRColor letterSectionColor]
                                                 size:barrierSize];
    bottomBarrier.position = CGPointMake(barrierXPos, bottomBarrierYPos);
    bottomBarrier.zPosition = zPos_LetterSectionBarrier_Vert;
    [self setBarrierPhysics];
    [self addChild:bottomBarrier];
    
    topBarrier = [SKSpriteNode spriteNodeWithColor:[LRColor letterSectionColor]
                                              size:barrierSize];
    topBarrier.position = CGPointMake(barrierXPos, topBarrierYPos);
    topBarrier.zPosition = zPos_LetterSectionBarrier_Vert;
    [self addChild:topBarrier];
}

- (void) addHorizontalBarriers
{
    CGFloat barrierHeight = kLetterBlockDimension;
    CGFloat barrierWidth = kSlotMarginWidth;
    CGSize barrierSize = CGSizeMake(barrierWidth, barrierHeight);

    CGPoint barrierPos;
    barrierPos.y = self.position.y;
    for (int i = 0; i < kWordMaximumLetterCount; i++)
    {
        barrierPos.x = [[self.letterSlots objectAtIndex:i] frame].origin.x - kSlotMarginWidth/2;
        SKSpriteNode *horBarrier = [SKSpriteNode spriteNodeWithColor:[LRColor letterSectionColor]
                                                                size:barrierSize];
        horBarrier.position = barrierPos;
        horBarrier.zPosition = zPos_LetterSectionBarrier_Hor;
        horBarrier.alpha = .5;
        [self addChild:horBarrier];
    }
}

- (void) setBarrierPhysics
{
    bottomBarrier.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottomBarrier.size];
    bottomBarrier.physicsBody.affectedByGravity = NO;
    bottomBarrier.physicsBody.dynamic = NO;
    bottomBarrier.physicsBody.friction = 1;
    bottomBarrier.name = NAME_SPRITE_BOTTOM_BARRIER;
    [[LRCollisionManager shared] setBitMasksForSprite:bottomBarrier];
    [[LRCollisionManager shared] addCollisionDetectionOfSpritesNamed:NAME_SPRITE_BOTTOM_BARRIER toSpritesNamed:NAME_SPRITE_SECTION_LETTER_BLOCK];
    [[LRCollisionManager shared] addContactDetectionOfSpritesNamed:NAME_SPRITE_BOTTOM_BARRIER toSpritesNamed:NAME_SPRITE_SECTION_LETTER_BLOCK];
    
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

- (NSMutableArray*) delayedLetters {
    if (!_delayedLetters) {
        _delayedLetters = [NSMutableArray new];
    }
    return _delayedLetters;
}

#pragma mark - LRLetterBlockControlDelegate Methods
#pragma mark Addition/Deletion
- (void) addEnvelopeToLetterSection:(id)envelope
{
    //If letters are being deleted currently, add them when they're done being deleted
    if (self.letterSectionState != LetterSectionStateNormal) {
        [self.delayedLetters addObject:envelope];
        return;
    }
    
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
    if (self.letterSectionState == LetterSectionStateDeletingLetters) {
        return;
    }
    
    LRCollectedEnvelope *envelopeToDelete = (LRCollectedEnvelope*)envelope;
    LRLetterSlot *deletionSlot = nil;
    int deletionIndex = 0;
    for (int i = 0; i < self.letterSlots.count; i++)
    {
        LRLetterSlot *slot = [self.letterSlots objectAtIndex:i];
        if (slot.currentBlock == envelopeToDelete) {
            deletionSlot = slot;
        }
        //If the slot that has to be deleted has been reached
        if (deletionSlot) {
            //If the current slot is the one being deleted
            if (deletionSlot == slot) {
                deletionSlot.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
                deletionIndex = i;
            }
            
            LRCollectedEnvelope *rightBlock;
            CompletionBlockType shiftDone;
            //If it's not the last block
            if (i == self.letterSlots.count - 1) {
                rightBlock = [LRLetterBlockGenerator createEmptySectionBlock];
                shiftDone = ^{
                    slot.currentBlock = rightBlock;
                    self.letterSectionState = LetterSectionStateNormal;
                    [self addDelayedLetters];
                };
            }
            else {
                rightBlock = [(LRLetterSlot*)[self.letterSlots objectAtIndex:i+1] currentBlock];
                shiftDone = ^{
                    slot.currentBlock = rightBlock;
                };
            }
            
            SKAction *shiftAnimation = [LREnvelopeAnimationBuilder shiftLetterInDirection:kLeftDirection
                                                                        withDelayForIndex:i - deletionIndex];
            SKAction *shift = [LREnvelopeAnimationBuilder actionWithCompletionBlock:shiftAnimation
                                                                              block:shiftDone];
            [slot.currentBlock runAction:shift];
        }
    }

    NSAssert(deletionSlot, @"Error: slot does not exist within array");
    [self updateSubmitButton];
}

- (void) addDelayedLetters
{
    for (id envelope in self.delayedLetters) {
        [self addEnvelopeToLetterSection:envelope];
    }
    [self.delayedLetters removeAllObjects];
    
}

#pragma mark Rearrangement
- (void) rearrangementHasBegunWithLetterBlock:(id)letterBlock
{
    self.touchedBlock = (LRCollectedEnvelope*)letterBlock;
    self.touchedBlock.zPosition = zPos_SectionBlock_Selected;
}

- (void) rearrangementHasFinishedWithLetterBlock:(id)letterBlock
{
    self.touchedBlock.zPosition = zPos_SectionBlock_Unselected;

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
        [self clearLetterSectionAnimated:YES];
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

- (void) clearLetterSectionAnimated:(BOOL)animated
{
    self.letterSectionState  = LetterSectionStateSubmittingWord;
    for (int i = 0; i < [self.letterSlots count]; i++)
    {
        LRLetterSlot *slot = [self.letterSlots objectAtIndex:i];
    
        CompletionBlockType complete = ^{
            slot.currentBlock = [LRLetterBlockGenerator createEmptySectionBlock];
            if (i == 0) {
                [self updateSubmitButton];
                self.letterSectionState = LetterSectionStateNormal;
                [self addDelayedLetters];
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

- (CGFloat) xPosFromSlotIndex:(int) index {
    //Calculate the distance between the edges of the screen and the first letter slot;
    CGFloat slotMargin = kSlotMarginWidth;
    CGFloat widthPerSlot = slotMargin + kLetterBlockDimension;
    // +kLetterBlockDimension for the submit button
    CGFloat letterSlotAreaWidth = widthPerSlot * kWordMaximumLetterCount + kLetterBlockDimension;
    CGFloat edgeBuffer = (self.size.width - letterSlotAreaWidth)/2;

    CGFloat leftOffset = -self.size.width/2 + (edgeBuffer + kLetterBlockDimension/2);
    CGFloat retVal = leftOffset + index * widthPerSlot;
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
