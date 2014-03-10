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
#import "LRDifficultyManager.h"
#import "LRScoreManager.h"

@interface LRGameStateManager ()

@property SKNode *managerParent;
@property (nonatomic) LRGameScene *gameScene;
@end

@implementation LRGameStateManager

static LRGameStateManager *_shared = nil;

#pragma mark - Public Properties


+ (LRGameStateManager*) shared
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
    }
    return self;
}

- (BOOL) isGameOver {
    return self.gameScene.gameState == LRGameStateGameOver;
}

- (BOOL) isGamePaused {
    return self.gameScene.gameState == LRGameStatePauseGame;
}

- (LRGameScene*)gameScene
{
    return (LRGameScene*)[self scene];
}

#pragma mark - Set Up

- (void) _setUpNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_gameOver:) name:GAME_STATE_GAME_OVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pauseGame) name:GAME_STATE_PAUSE_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_unpauseGame) name:GAME_STATE_CONTINUE_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newGame:) name:GAME_STATE_NEW_GAME object:nil];
}

- (void) _setUpManagerHierarchy
{
    //This function makes the manager children so they can use the LRGameStateDelegate methods
    _managerParent = [SKNode new];
    [_managerParent addChild:[LRScoreManager shared]];
    [self addChild:_managerParent];
}

#pragma mark - Game State Functions

- (void) _newGame:(NSNotification*)notification
{
    LRGamePlayLayer *gpl = [self.gameScene gamePlayLayer];
    if ([[[notification userInfo] objectForKey:@"devpause"] boolValue]) {
        [gpl.mainGameSection removeAllActions];
    }
    
    [[LRDifficultyManager shared] setLevel:1];
    [self.gameScene setGameState:LRGameStateNewGame];

}

- (void) _gameOver:(NSNotification*)notification
{
    self.gameScene.gameState = LRGameStateGameOver;
    
    NSLog(@"Game over");
    //Make all of the objects in the game non-touch responsive
    if (![[[notification userInfo] objectForKey:@"devpause"] isEqual: @(true)]) {
        [self _showGameOverLabel];

    }
}

- (void) _pauseGame
{
    self.gameScene.gameState = LRGameStatePauseGame;
    LRGamePlayLayer *gpl = [self.gameScene gamePlayLayer];
    gpl.paused = YES;
    [gpl.mainGameSection enumerateChildNodesWithName:NAME_SPRITE_MOVING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        [node setUserInteractionEnabled:NO];
    }];
    [gpl.letterSection setUserInteractionEnabled:NO];
    
    if (!gpl.devPause) {
        gpl.devPause = [[LRDevPauseMenuVC alloc] init];
        CGRect devPauseFrame = gpl.devPause.view.frame;
        devPauseFrame.size = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
        gpl.devPause.view.frame = devPauseFrame;        
        [gpl.scene.view addSubview:gpl.devPause.view];
    }
}

- (void) _unpauseGame
{
    self.gameScene.gameState = LRGameStateUnpauseGame;
    LRGamePlayLayer *gpl = [self.gameScene gamePlayLayer];
    if (gpl.devPause) {
        gpl.devPause = nil;
    }
    gpl.paused = NO;
    [gpl.mainGameSection enumerateChildNodesWithName:NAME_SPRITE_MOVING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        [node setUserInteractionEnabled:YES];
    }];
    [gpl.letterSection setUserInteractionEnabled:YES];
}


- (void) _showGameOverLabel
{
    SKLabelNode *gameOverLabel = [[SKLabelNode alloc] init];
    gameOverLabel.text = @"Game Over";
    gameOverLabel.fontColor = [LRColor redColor];
    gameOverLabel.fontSize = 50;
    gameOverLabel.zPosition = 500;
    __block LRGamePlayLayer *gpl = [self.gameScene gamePlayLayer];
    
    [gpl.pauseButton setIsEnabled:NO];
    
    SKAction *showLabel = [SKAction runBlock:^{
        [gpl addChild:gameOverLabel];
    }];
    SKAction *delay = [SKAction waitForDuration:3.5];
    SKAction *restartLevel = [SKAction runBlock:^{
        [gpl removeChildrenInArray:[NSArray arrayWithObject:gameOverLabel]];
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_NEW_GAME object:self];
    }];
    [self runAction:[SKAction sequence:@[showLabel, delay, restartLevel]]];
}

@end
