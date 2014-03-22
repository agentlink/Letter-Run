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

static const CGFloat kMailmanAreaWidth          = 70.0;

@interface LRMainGameSection () <LRMovingBlockTouchDelegate>

//Children
@property SKSpriteNode *backgroundImage;

//Slot logic
@property LRSlotManager *letterSlotManager;
@property NSMutableArray *envelopesOnScreen;

//Pause and Game Over timing logic
@property NSTimeInterval nextDropTime;
@property NSTimeInterval dropDelayForAfterPause;
@property NSTimeInterval previousRunLoopTime;
@property NSTimeInterval previousDropTime;
@property BOOL newGameWillBegin;

@end

@implementation LRMainGameSection
@synthesize nextDropTime, dropDelayForAfterPause, previousRunLoopTime, newGameWillBegin, previousDropTime;
#pragma mark - Initialization Methods -

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.envelopesOnScreen = [NSMutableArray new];
        self.letterSlotManager = [LRSlotManager new];
        self.envelopeTouchEnabled = YES;
        self.newGameWillBegin = YES;
        previousDropTime = 0.0;
        dropDelayForAfterPause = kGameLoopResetValue;
    }
    return self;
}

- (void)createSectionContent
{
    //Background
    self.backgroundImage = [[SKSpriteNode alloc] initWithImageNamed:@"mainSection.jpg"];
    self.backgroundImage.size = self.size;
    [self addChild:self.backgroundImage];
    
    //Mailman section
    LRMailmanArea *mailmanArea = [[LRMailmanArea alloc] initWithSize:CGSizeMake(kMailmanAreaWidth, self.size.height)];
    mailmanArea.position = (CGPoint){(mailmanArea.size.width - self.size.width)/2, 0};
    self.mailmanArea = mailmanArea;
    [self addChild:self.mailmanArea];
}

#pragma mark - Update Loop Methods -
#pragma mark Time Methods
- (void)update:(NSTimeInterval)currentTime
{
    //Check whether the update loop should continue
    if (newGameWillBegin) {
        nextDropTime = currentTime;
        newGameWillBegin = FALSE;
    }

    //Shift the envelopes...
    CGFloat timeDifference = currentTime - previousRunLoopTime;
    [self _shiftEnvelopesForTimeDifference:timeDifference];
    [self _checkEnvelopesForRemoval];
    if ([self _shouldGenerateEnvelopesForTime:currentTime]) {
        [self generateEnvelopes];
        float letterDropPeriod = [[LRDifficultyManager shared] letterDropPeriod];
        nextDropTime += letterDropPeriod;
        previousDropTime = currentTime;
    }
    previousRunLoopTime = currentTime;
}

- (BOOL)_shouldGenerateEnvelopesForTime:(NSTimeInterval)currentTime
{
    return (nextDropTime <= currentTime &&
            ![[LRGameStateManager shared] isGameOver] &&
            ![[LRGameStateManager shared] isGamePaused]);
}

#pragma mark Letter Addition and Removal
- (void)generateEnvelopes
{
    int i = 0;
    for (i = 0; i < [[LRDifficultyManager shared] numLettersPerDrop]; i++) {
        LRMovingEnvelope *envelope = [LRLetterBlockGenerator createRandomEnvelope];
        [self.letterSlotManager addEnvelope:envelope];
        [self addMovingBlockToScreen:envelope];
    }
}

- (void)addMovingBlockToScreen:(LRMovingEnvelope *)movingBlock
{
    //Set the touch delegate
    movingBlock.touchDelegate = self;
    //Add the envelope to teh screen and to the array
    [self.envelopesOnScreen addObject:movingBlock];
    [self addChild:movingBlock];
}

///Pass in an array of LRMovingBlocks to delete
- (void)removeMovingBlocksFromScreen:(NSArray *)letterBlocks
{
    //Remove the envelope from the screen and the array
    [self.envelopesOnScreen removeObjectsInArray:letterBlocks];
    [self removeChildrenInArray:letterBlocks];
}

- (void)clearMainGameSection
{
    [self.letterSlotManager resetSlots];
    [self removeChildrenInArray:self.envelopesOnScreen];
    [self.envelopesOnScreen removeAllObjects];
}

#pragma mark Letter Movement/Touch

- (void)setEnvelopeTouchEnabled:(BOOL)envelopeTouchEnabled
{
    _envelopeTouchEnabled = envelopeTouchEnabled;
    for (LRMovingEnvelope *envelope in self.envelopesOnScreen) {
        envelope.userInteractionEnabled = envelopeTouchEnabled;
    }
}

- (void)_shiftEnvelopesForTimeDifference:(CGFloat)timeDifference
{
    CGFloat secondsToCrossScreen = 4.5;
    //TODO: get this from the difficulty manager
    CGFloat pixelsPerSecond = SCREEN_WIDTH / secondsToCrossScreen;
    for (LRMovingEnvelope* envelope in self.envelopesOnScreen) {
        //Shift the block down...
        CGFloat distance = pixelsPerSecond * timeDifference;
        envelope.position = CGPointMake(envelope.position.x - distance,
                                     envelope.position.y);
    }
}

- (void)_checkEnvelopesForRemoval
{
    NSMutableArray *envelopesToRemove = [NSMutableArray new];
    for (LRMovingEnvelope* envelope in self.envelopesOnScreen)
    {
        if ([self _envelopeHasCrossedCollectionThreshold:envelope])
        {
            if (envelope.selected) {
                [self.letterAdditionDelegate addEnvelopeToLetterSection:envelope];
            }
            [envelopesToRemove addObject:envelope];
        }
    }
    [self removeMovingBlocksFromScreen:envelopesToRemove];
}

- (BOOL)_envelopeHasCrossedCollectionThreshold:(LRMovingEnvelope *)envelope
{
    return (envelope.position.x < self.mailmanArea.position.x);
}

#pragma mark - Delegate Methods -
#pragma mark LRMovingBlockTouchDelegate Methods

- (void)playerSelectedMovingBlock:(LRMovingEnvelope *)movingBlock
{
    movingBlock.selected = !movingBlock.selected;
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

- (void)gameStatePaused:(NSTimeInterval)currentTime
{
    [self enumerateChildNodesWithName:NAME_SPRITE_MOVING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        [node setUserInteractionEnabled:NO];
    }];
    if (dropDelayForAfterPause == kGameLoopResetValue)
        dropDelayForAfterPause = currentTime - previousDropTime;
}

- (void)gameStateUnpaused:(NSTimeInterval)currentTime
{
    nextDropTime = currentTime + dropDelayForAfterPause;
    previousRunLoopTime = currentTime;
    dropDelayForAfterPause = kGameLoopResetValue;
    [self enumerateChildNodesWithName:NAME_SPRITE_MOVING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        [node setUserInteractionEnabled:YES];
    }];
}
@end
