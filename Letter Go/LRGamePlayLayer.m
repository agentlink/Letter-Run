//
//  LRGamePlayLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGamePlayLayer.h"
#import "LRLetterBlockGenerator.h"
#import "LRCollisionManager.h"
#import "LRGameStateManager.h"
#import "LRDifficultyManager.h"
#import "LRFallingEnvelopeSlotManager.h"
#import "LRPositionConstants.h"

@interface LRGamePlayLayer ()
@property LRFallingEnvelopeSlotManager *letterSlots;

@property BOOL newGame;
@property NSTimeInterval nextDropTime;
@property NSTimeInterval pauseTime;

@end

@implementation LRGamePlayLayer
@synthesize newGame, pauseTime, nextDropTime;

#pragma mark - Set Up/Initialization

- (id) init
{
    if (self = [super init])
    {
        self.pauseTime = kGameLoopResetValue;
        self.name = NAME_LAYER_GAME_PLAY;
        newGame = TRUE;
        self.letterSlots = [[LRFallingEnvelopeSlotManager alloc] init];
        [self createLayerContent];
    }
    return self;
}


- (void) createLayerContent
{
    [self addChild:self.healthSection];
    [self addChild:self.letterSection];
    [self addChild:self.pauseButton];
}

#pragma mark - Layer Content Set Up

- (LRHealthSection*) healthSection
{
    if (!_healthSection) {
        _healthSection = [[LRHealthSection alloc] initWithSize:CGSizeMake(self.size.width, kSectionHeightHealth)];
        _healthSection.position = CGPointMake(0, self.size.height/2 - kSectionHeightHealth/2);
        _healthSection.zPosition = zPos_HealthSection;
    }
    return _healthSection;
}

- (LRLetterSection*) letterSection
{
    if (!_letterSection) {
        _letterSection = [[LRLetterSection alloc] initWithSize:CGSizeMake(self.size.width, kSectionHeightLetterSection)];
        _letterSection.position = CGPointMake(self.position.x - self.size.width/2, 0 - self.size.height/2 + self.letterSection.size.height/2);
        _letterSection.zPosition = zPos_LetterSection;
    }
    return _letterSection;
}

- (LRButton*) pauseButton
{
    if (!_pauseButton) {
        _pauseButton = [[LRButton alloc] initWithImageNamedNormal:@"Pause_Selected.png" selected:@"Pause_Unselected.png"];
        [_pauseButton setScale:.7];
        [_pauseButton setTouchUpInsideTarget:self action:@selector(pauseButtonPressed)];
        _pauseButton.position = CGPointMake(0 - SCREEN_WIDTH/2 + _pauseButton.size.width/2, SCREEN_HEIGHT/2 - self.healthSection.size.height - _pauseButton.size.height/2);
        _pauseButton.zPosition = zPos_PauseButton;
    }
    return _pauseButton;

}

- (void) pauseButtonPressed
{
    NSString *notifName = ([[LRGameStateManager shared] isGamePaused]) ? GAME_STATE_CONTINUE_GAME : GAME_STATE_PAUSE_GAME;
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:nil];
}

#pragma mark - Letter Drop Functions

- (void) update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    //If the game is over
    if ([[LRGameStateManager shared] isGameOver]) {
        newGame = TRUE;
        //Reset the falling letters list
        [self.letterSlots resetSlots];
        return;
    }
    //If the game is paused
    else if ([[LRGameStateManager shared] isGamePaused]) {
        if (pauseTime != kGameLoopResetValue)
            pauseTime = nextDropTime - currentTime;
        return;
    }
    //If a new game has just begun
    else if (newGame) {
        nextDropTime = currentTime;
        newGame = FALSE;
    }
    //If the game has just been unpaused
    else if (pauseTime != kGameLoopResetValue) {
        nextDropTime = currentTime + pauseTime;
        pauseTime = kGameLoopResetValue;
    }
    
    if (currentTime >= nextDropTime) {
        int i = 0;
        for (i = 0; i < [[LRDifficultyManager shared] numLettersPerDrop]; i++) {
            [self dropLetter];
        }
        nextDropTime = currentTime + [[LRDifficultyManager shared] letterDropPeriod];
    }
}

- (void) dropLetter
{
    LRFallingEnvelope *envelope = [LRLetterBlockGenerator createRandomEnvelope];
    [self.letterSlots addEnvelope:envelope];
    [self addChild:envelope];
    [envelope dropEnvelopeWithSwing];
}

#pragma mark - Board Properties

- (CGPoint) flungEnvelopeDestination
{
    return CGPointZero;
}

@end
