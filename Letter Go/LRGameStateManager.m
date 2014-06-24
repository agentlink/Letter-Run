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
#import "LRDifficultyManager.h"
#import "LRGameOverMenu.h"

static const BOOL kLRGameStateManagerUseBlur = NO;

@interface LRGameStateManager ()

@property SKNode *managerParent;
@property (nonatomic) LRGameScene *gameScene;
@property (nonatomic) LRDevPauseViewController *devPauseVC;

@property (nonatomic, readwrite) BOOL isGameOver;
@property (nonatomic, readwrite) BOOL isGamePaused;
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
        [self _setUpNotifications];
        [self _setUpManagerHierarchy];
    }
    return self;
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
    [_managerParent addChild:[LRDifficultyManager shared]];
    [self addChild:_managerParent];
    
    //initialize the progress manager
}

#pragma mark - Game State Functions

- (void)_newGame:(NSNotification *)notification
{
    LRGamePlayLayer *gpl = [self.gameScene gamePlayLayer];
    if ([[[notification userInfo] objectForKey:@"devpause"] boolValue]) {
        [gpl.mainGameSection removeAllActions];
    }
    self.isGameOver = NO;
    [[LRProgressManager shared] resetRoundProgress];
}

- (void)_gameOver:(NSNotification *)notification
{
    LRGamePlayLayer *gpl = [self.gameScene gamePlayLayer];
    self.isGameOver = YES;
    [[LRManfordAIManager shared] resetEnvelopeIDs];
    NSLog(@"Game over");
    //Make all of the objects in the game non-touch responsive
    if (![[[notification userInfo] objectForKey:@"devpause"] isEqual: @(true)]) {
        [LRGameOverMenu presentGameOverMenuFromNode:gpl.mainGameSection];
    }
}

- (void)_pauseGame
{
    if (kLRGameStateManagerUseBlur) {
        [[[LRGameStateManager shared] gameScene] blurSceneWithCompletion:nil];
    }
    self.isGamePaused = YES;
    self.gameScene.gamePlayLayer.paused = YES;
    self.gameScene.backgroundLayer.paused = YES;
    [self showPauseMenu:YES];
}

- (void)_unpauseGame
{
    CompletionBlockType unpauseBlock = ^{
        self.isGamePaused = NO;
        self.gameScene.gamePlayLayer.paused = NO;
        self.gameScene.backgroundLayer.paused = NO;
    };
    [self showPauseMenu:NO];
    if (kLRGameStateManagerUseBlur) {
        [[[LRGameStateManager shared] gameScene] unblurSceneWithCompletion:unpauseBlock];
    }
    else {
        unpauseBlock();
    }
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
