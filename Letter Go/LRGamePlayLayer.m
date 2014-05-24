//
//  LRGamePlayLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGamePlayLayer.h"
#import "LRLetterBlockBuilder.h"
#import "LRGameStateManager.h"
#import "LRRowManager.h"
#import "LRPositionConstants.h"
#import "LRColor.h"

NSString * const kLRGamePlayLayerHealthSectionName = @"healthSection";
NSString * const kLRGamePlayLayerLetterSectionName = @"letterSection";


@interface LRGamePlayLayer ()
@property LRRowManager *letterSlots;

@property (nonatomic, strong) LRHealthSection *healthSection;
@property (nonatomic, strong) LRLetterSection *letterSection;
@property (nonatomic, strong) LRMainGameSection *mainGameSection;
@property (nonatomic, strong) LRButtonSection *buttonSection;
@property (nonatomic, strong) LRButton *pauseButton;
@property (nonatomic, strong) LRDevPauseViewController *devPause;

@end

@implementation LRGamePlayLayer

#pragma mark - Set Up/Initialization

- (id) init
{
    if (self = [super init])
    {
        [self setSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self setPosition:CGPointMake(self.size.width/2, self.size.height/2)];
        [self setUserInteractionEnabled:YES];
        
        self.color = [LRColor gamePlayLayerBackgroundColor];
        [self createLayerContent];
    }
    return self;
}


- (void)createLayerContent
{
    [self addChild:self.buttonSection];
    [self addChild:self.healthSection];
    [self addChild:self.letterSection];
    [self addChild:self.mainGameSection];
    [self addChild:self.pauseButton];
}

#pragma mark - Layer Content Set Up -
#pragma mark Sections
- (LRHealthSection *)healthSection
{
    if (!_healthSection) {
        CGFloat healthSectionYPos = - self.size.height/2 + kSectionHeightLetterSection + kSectionHeightButtonSection +kSectionHeightHealthSection/2;
        _healthSection = [[LRHealthSection alloc] initWithSize:CGSizeMake(self.size.width, kSectionHeightHealthSection)];
        _healthSection.position = CGPointMake(0, healthSectionYPos);
        _healthSection.zPosition = zPos_HealthSection;
        _healthSection.name = kLRGamePlayLayerHealthSectionName;
    }
    return _healthSection;
}

- (LRLetterSection *)letterSection
{
    if (!_letterSection) {
        _letterSection = [[LRLetterSection alloc] initWithSize:CGSizeMake(self.size.width, kSectionHeightLetterSection)];
        _letterSection.position = CGPointMake(self.position.x - self.size.width/2,
                                              0 - self.size.height/2 + self.letterSection.size.height/2 + kSectionHeightButtonSection);
        _letterSection.zPosition = zPos_LetterSection;
        _letterSection.name = kLRGamePlayLayerLetterSectionName;
    }
    return _letterSection;
}

- (LRMainGameSection *)mainGameSection {
    if (!_mainGameSection) {
        CGFloat mainGameSectionXPos = 0;
        CGFloat mainGameSectionYPos = (kSectionHeightLetterSection + kSectionHeightHealthSection + kSectionHeightButtonSection)/2;
        
        _mainGameSection = [[LRMainGameSection alloc] initWithSize:CGSizeMake(SCREEN_WIDTH, kSectionHeightMainSection)];
        _mainGameSection.position = CGPointMake(mainGameSectionXPos, mainGameSectionYPos);
        _mainGameSection.zPosition = zPos_MainGameSection;
        _mainGameSection.color = [LRColor clearColor];
    }
    return _mainGameSection;
}

- (LRButtonSection *)buttonSection
{
    if (!_buttonSection) {
        CGFloat buttonSectionXPos = 0;
        CGFloat buttonSectionYPos = -self.size.height/2 + kSectionHeightButtonSection/2;
        _buttonSection = [[LRButtonSection alloc] initWithSize:CGSizeMake(SCREEN_WIDTH, kSectionHeightButtonSection)];
        _buttonSection.position = CGPointMake(buttonSectionXPos, buttonSectionYPos);
        _buttonSection.zPosition = zPos_ButtonSection;
    }
    return _buttonSection;
    
}

- (LRButton *)pauseButton
{
    if (!_pauseButton) {
        _pauseButton = [[LRButton alloc] initWithImageNamed:@"pause-button" withDisabledOption:NO];
        [_pauseButton setScale:.7];
        [_pauseButton setTouchUpInsideTarget:self action:@selector(pauseButtonPressed)];
        _pauseButton.position = CGPointMake(0 - SCREEN_WIDTH/2 + _pauseButton.size.width/2, SCREEN_HEIGHT/2 - _pauseButton.size.height/2);
        _pauseButton.zPosition = zPos_PauseButton;
    }
    return _pauseButton;
}

- (void)pauseButtonPressed
{
    NSString *notifName = ([[LRGameStateManager shared] isGamePaused]) ? GAME_STATE_CONTINUE_GAME : GAME_STATE_PAUSE_GAME;
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:nil];
}

#pragma mark - LRGameUpdateDelegate
- (void)gameStateNewGame
{
    self.pauseButton.isEnabled = YES;
}

- (void)gameStateGameOver
{
    self.pauseButton.isEnabled = NO;
}

@end