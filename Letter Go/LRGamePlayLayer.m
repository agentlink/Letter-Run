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
#import "LRSlotManager.h"
#import "LRPositionConstants.h"

@interface LRGamePlayLayer ()
@property LRSlotManager *letterSlots;

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
        [self setSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self setPosition:CGPointMake(self.size.width/2, self.size.height/2)];
        [self setUserInteractionEnabled:YES];
        
        self.pauseTime = kGameLoopResetValue;
        self.name = NAME_LAYER_GAME_PLAY;
        newGame = TRUE;
        [self createLayerContent];
    }
    return self;
}


- (void) createLayerContent
{
    [self addChild:self.healthSection];
    [self addChild:self.letterSection];
    [self addChild:self.mainGameSection];
    [self addChild:self.pauseButton];
}

#pragma mark - Layer Content Set Up -
#pragma mark Sections
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

- (LRScreenSection*) mainGameSection {
    if (!_mainGameSection) {
        CGFloat mainGameSectionXPos = 0;
        CGFloat mainGameSectionYPos = kSectionHeightLetterSection/2;
        
        _mainGameSection = [[LRMainGameSection alloc] initWithSize:CGSizeMake(SCREEN_WIDTH, kSectionHeightMainSection)];
        _mainGameSection.position = CGPointMake(mainGameSectionXPos, mainGameSectionYPos);
        _mainGameSection.letterAdditionDelegate = self.letterSection;
        _mainGameSection.zPosition = zPos_MainGameSection;
        _mainGameSection.color = [LRColor skyColor];
//        _mainGameSection.alpha = 1.0;
        
    }
    return _mainGameSection;
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

@end