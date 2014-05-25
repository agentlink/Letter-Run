//
//  LRGameStateManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/4/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGameStateManager.h"
#import "LRGameScene.h"

#import "LRDictionaryChecker.h"
#import "LRProgressManager.h"
#import "LRScoreManager.h"
#import "LRManfordAIManager.h"

@interface LRGameStateManager ()

@property SKNode *managerParent;
@property (nonatomic) LRGameScene *gameScene;
@property (nonatomic) LRDevPauseViewController *devPauseVC;
@property (nonatomic) SKLabelNode *gameOverLabel;
@end

@implementation LRGameStateManager

static LRGameStateManager *_shared = nil;

#pragma mark - Public Properties


+ (LRGameStateManager *)shared
{
    //This @synchronized line is for multithreading
    @synchronized (self)
    {
		if (!_shared)
        {
			_shared = [[LRGameStateManager alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init])
    {
        //Set up the dictionary
        [LRDictionaryChecker shared];
        [self _setUpNotifications];
        [self _setUpManagerHierarchy];
        //preload the game over label
        (void)self.gameOverLabel;
    }
    return self;
}

- (BOOL) isGameOver {
    return self.gameScene.gameState == LRGameStateGameOver;
}

- (BOOL) isGamePaused {
    return self.gameScene.gameState == LRGameStatePauseGame;
}

- (LRGameScene *)gameScene
{
    return (LRGameScene *)[self scene];
}

#pragma mark - Set Up

- (void)_setUpNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_gameOver:) name:GAME_STATE_GAME_OVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pauseGame) name:GAME_STATE_PAUSE_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_unpauseGame) name:GAME_STATE_CONTINUE_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newGame:) name:GAME_STATE_NEW_GAME object:nil];
}

- (void)_setUpManagerHierarchy
{
    //This function makes the manager children so they can use the LRGameStateDelegate methods
    _managerParent = [SKNode new];
    [_managerParent addChild:[LRScoreManager shared]];
    [self addChild:_managerParent];
}

#pragma mark - Game State Functions

- (void)_newGame:(NSNotification *)notification
{
    LRGamePlayLayer *gpl = [self.gameScene gamePlayLayer];
    if ([[[notification userInfo] objectForKey:@"devpause"] boolValue]) {
        [gpl.mainGameSection removeAllActions];
    }
    
    [[LRProgressManager shared] resetRoundProgress];
    [self.gameScene setGameState:LRGameStateNewGame];
}

- (void)_gameOver:(NSNotification *)notification
{
    self.gameScene.gameState = LRGameStateGameOver;
    [[LRManfordAIManager shared] resetEnvelopeIDs];
    NSLog(@"Game over");
    //Make all of the objects in the game non-touch responsive
    if (![[[notification userInfo] objectForKey:@"devpause"] isEqual: @(true)]) {
        [self _showGameOverLabelForDuration:3.5];

    }
}

- (void)_pauseGame
{
    [self showPauseMenu:YES];
    [[[LRGameStateManager shared] gameScene] blurSceneWithCompletion:^{
    }];
    self.gameScene.gameState = LRGameStatePauseGame;
    self.gameScene.gamePlayLayer.paused = YES;
    self.gameScene.backgroundLayer.paused = YES;

}

- (void)_unpauseGame
{
    [self showPauseMenu:NO];
    [[[LRGameStateManager shared] gameScene] unblurSceneWithCompletion:^{
        self.gameScene.gameState = LRGameStateUnpauseGame;
        self.gameScene.gamePlayLayer.paused = NO;
        self.gameScene.backgroundLayer.paused = NO;
    }];
}

- (void)showPauseMenu:(BOOL)show
{
    if (!self.devPauseVC) {
        self.devPauseVC = [[LRDevPauseViewController alloc] init];
    }
    if (show) {
        [self.gameScene.view addSubview:self.devPauseVC.view];
        [self.gameScene.view bringSubviewToFront:self.devPauseVC.view];
    }
    else {
        [self.devPauseVC.view removeFromSuperview];
    }
}

- (void)_showGameOverLabelForDuration:(CGFloat)duration
{
    __block LRGamePlayLayer *gpl = [self.gameScene gamePlayLayer];
    [gpl.pauseButton setIsEnabled:NO];
    SKAction *showLabel = [SKAction runBlock:^{
        [gpl addChild:self.gameOverLabel];
    }];
    SKAction *delay = [SKAction waitForDuration:duration];
    SKAction *restartLevel = [SKAction runBlock:^{
        [self.gameOverLabel removeFromParent];
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_NEW_GAME object:nil];
    }];
    [self runAction:[SKAction sequence:@[showLabel, delay, restartLevel]]];
}

- (SKLabelNode *)gameOverLabel
{
    if (!_gameOverLabel) {
        LRFont *displayFont = [LRFont displayTextFontWithSize:100];
        _gameOverLabel = [[SKLabelNode alloc] init];
        _gameOverLabel.text = @"Game Over";
        _gameOverLabel.fontName = displayFont.familyName;
        _gameOverLabel.fontSize = 80.0;
        _gameOverLabel.fontColor = [LRColor gameOverLabelColor];
        _gameOverLabel.zPosition = 500;
        _gameOverLabel.position = CGPointMake(0, (SCREEN_HEIGHT - kSectionHeightMainSection)/2);
    }
    return _gameOverLabel;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
