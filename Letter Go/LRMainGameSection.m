//
//  LRMainGameSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMainGameSection.h"
#import "LRGameStateManager.h"

@interface LRMainGameSection () <LRMovingBlockTouchDelegate>

@property NSMutableArray *envelopesOnScreen;
@property NSTimeInterval initialTime;
@end

@implementation LRMainGameSection

#pragma mark - Initialization Methods -

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.envelopesOnScreen = [NSMutableArray new];
    }
    return self;
}

- (void) createSectionContent
{
    
}

#pragma mark - Letter Addition/Removal -
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

#pragma mark - Letter Movement/Touch -

- (void) update:(NSTimeInterval)currentTime
{
    //If the game is over or paused
    if ([[LRGameStateManager shared] isGameOver] || [[LRGameStateManager shared] isGamePaused]) {
        self.initialTime = kGameLoopResetValue;
        return;
    }
    //If its a new game or the game is unpaused
    else if (self.initialTime == kGameLoopResetValue) {
        self.initialTime = currentTime;
        return;
    }
    
    CGFloat timeDifference = currentTime - self.initialTime;
    //Shift the envelopes...
    [self shiftEnvelopesForTimeDifference:timeDifference];
    //...and generate letters
    //TODO: have MainGameSection handle envelope dropping
    self.initialTime = currentTime;
}

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

#pragma mark LRMovingBlockTouchDelegate Methods
- (void) playerSelectedMovingBlock:(LRMovingBlock *)movingBlock
{
    //TODO: replace this with direct access to letter section
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADDED_LETTER
                                                        object:self
                                                      userInfo:[movingBlock addLetterDictionary]];
    [self removeMovingBlockFromScreen:movingBlock];
}


@end
