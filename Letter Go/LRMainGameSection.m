//
//  LRMainGameSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMainGameSection.h"
#import "LRGameStateManager.h"
#import "LRLetterBlockGenerator.h"
#import "LRSlotManager.h"
#import "LRDifficultyManager.h"

@interface LRMainGameSection () <LRMovingBlockTouchDelegate>

@property LRSlotManager *letterSlotManager;
@property NSMutableArray *envelopesOnScreen;

@property NSTimeInterval nextDropTime;
@property NSTimeInterval timeOfPause;
@property NSTimeInterval previousDropTime;
@property BOOL newGameWillBegin;


@end

@implementation LRMainGameSection
@synthesize nextDropTime, timeOfPause, previousDropTime, newGameWillBegin;
#pragma mark - Initialization Methods -

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.envelopesOnScreen = [NSMutableArray new];
        self.letterSlotManager = [LRSlotManager new];
        self.envelopeTouchEnabled = YES;
    }
    return self;
}


#pragma mark - Update Loop Methods -
#pragma mark Time Methods
- (void) update:(NSTimeInterval)currentTime
{
    //Check whether the update loop should continue
    BOOL continueGameLoop = [self updateWithTimeAndContinue:currentTime];
    
    if (continueGameLoop) {
        //Shift the envelopes...
        CGFloat timeDifference = currentTime - previousDropTime;
        [self shiftEnvelopesForTimeDifference:timeDifference];
        //If the time to drop the envelopes has come, drop'em and get the next drop time
        if (nextDropTime <= currentTime &&
            ![[LRGameStateManager shared] isGameOver]) {
            [self generateEnvelopes];
            float letterDropPeriod = [[LRDifficultyManager shared] letterDropPeriod];
            nextDropTime += letterDropPeriod;
        }
    }
    previousDropTime = currentTime;
}

///Returns whether or not the update loop should continue
- (BOOL) updateWithTimeAndContinue:(NSTimeInterval)currentTime
{
    //If the game has just been paused, set the time of pause to the current time
    if ([[LRGameStateManager shared] isGamePaused]) {
        if (timeOfPause == kGameLoopResetValue)
            timeOfPause = currentTime;
        return NO;
    }
    //If the game has been unpaused, use the time of pause to calculate the new next drop time
    else if (timeOfPause != kGameLoopResetValue) {
        NSTimeInterval lengthOfPauseTime = currentTime - timeOfPause;
        nextDropTime += lengthOfPauseTime;
        timeOfPause = kGameLoopResetValue;
        return YES;
    }
    //If a new game has just begun, immediately drop letters
    else if (newGameWillBegin) {
        nextDropTime = currentTime;
        newGameWillBegin = FALSE;
        return YES;
    }
    
    return YES;
}

#pragma mark Letter Addition and Removal
- (void) generateEnvelopes
{
    int i = 0;
    for (i = 0; i < [[LRDifficultyManager shared] numLettersPerDrop]; i++) {
        LRMovingBlock *envelope = [LRLetterBlockGenerator createRandomEnvelope];
        [self.letterSlotManager addEnvelope:envelope];
        [self addMovingBlockToScreen:envelope];
    }
}

- (void) addMovingBlockToScreen:(LRMovingBlock *)movingBlock
{
    //Set the touch delegate
    movingBlock.touchDelegate = self;
    //Add the envelope to teh screen and to the array
    [self.envelopesOnScreen addObject:movingBlock];
    [self addChild:movingBlock];
}


- (void) removeMovingBlockFromScreen:(LRMovingBlock*)letterBlock
{
    //Remove the envelope from the screen and the array
    [self.envelopesOnScreen removeObject:letterBlock];
    [self removeChildrenInArray:@[letterBlock]];
}

- (void) clearMainGameSection
{
    [self.letterSlotManager resetSlots];
    [self removeChildrenInArray:self.envelopesOnScreen];
    [self.envelopesOnScreen removeAllObjects];
}

#pragma mark Letter Movement/Touch

- (void) shiftEnvelopesForTimeDifference:(CGFloat)timeDifference
{
    NSMutableArray *blocksToRemove = [NSMutableArray new];
    CGFloat secondsToCrossScreen = 5.0;
    //TODO: get this from the difficulty manager
    CGFloat pixelsPerSecond = SCREEN_WIDTH / secondsToCrossScreen;
    for (LRMovingBlock* block in self.envelopesOnScreen) {
        //Shift the block down...
        CGFloat distance = pixelsPerSecond * timeDifference;
        block.position = CGPointMake(block.position.x - distance,
                                     block.position.y);
        //...and remove it if it's off screen
        if (!CGRectIntersectsRect(block.frame, self.frame) &&
            block.frame.origin.x < 0)
        {
            [blocksToRemove addObject:block];
        }
    }
    [self removeChildrenInArray:blocksToRemove];
}

- (void) setEnvelopeTouchEnabled:(BOOL)envelopeTouchEnabled
{
    _envelopeTouchEnabled = envelopeTouchEnabled;
    for (LRMovingBlock *envelope in self.envelopesOnScreen) {
        envelope.userInteractionEnabled = envelopeTouchEnabled;
    }
}

#pragma mark - Delegate Methods -
#pragma mark LRMovingBlockTouchDelegate Methods

- (void) playerSelectedMovingBlock:(LRMovingBlock *)movingBlock
{
    [self.letterAdditionDelegate addEnvelopeToLetterSection:movingBlock];
    [self removeMovingBlockFromScreen:movingBlock];
}

#pragma mark LRGameStateDelegate Methods

- (void)gameStateNewGame
{
    self.envelopeTouchEnabled = YES;
    [self clearMainGameSection];
}

- (void)gameStateGameOver
{
    self.envelopeTouchEnabled = NO;
    newGameWillBegin = YES;
}
@end
