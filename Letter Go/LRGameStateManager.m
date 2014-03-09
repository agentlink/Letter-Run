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
@property (nonatomic) BOOL gameIsOver;
@property (nonatomic) BOOL gameIsPaused;
@property (nonatomic) LRGameScene *gameScene;
@end

@implementation LRGameStateManager

static LRGameStateManager *_shared = nil;

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

- (void) _setUpNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver:) name:GAME_STATE_GAME_OVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseGame) name:GAME_STATE_PAUSE_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unpauseGame) name:GAME_STATE_CONTINUE_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame:) name:GAME_STATE_NEW_GAME object:nil];
}

- (void) _setUpManagerHierarchy
{
    //This function makes the manager children so they can use the LRGameStateDelegate methods
    _managerParent = [SKNode new];
    [_managerParent addChild:[LRScoreManager shared]];
    [self addChild:_managerParent];
}

- (BOOL) isLetterSectionFull
{
    LRLetterSection *letterSection = [[self.gameScene gamePlayLayer] letterSection];
    return ([letterSection numLettersInSection] == kWordMaximumLetterCount);
}

#pragma mark - Game State Functions

- (void) newGame:(NSNotification*)notification
{
    [self.gameScene setGameState:LRGameStateNewGame];
    
    LRGamePlayLayer *gpl = [self.gameScene gamePlayLayer];
    if ([[[notification userInfo] objectForKey:@"devpause"] boolValue]) {
        [gpl.mainGameSection removeAllActions];
    }
    
    [self clearBoard];
    [[LRDifficultyManager shared] setLevel:1];
    self.gameIsOver = FALSE;
    [gpl.pauseButton setIsEnabled:YES];
}

- (void) clearBoard
{
    LRGamePlayLayer *gpl = [self.gameScene gamePlayLayer];
    [gpl.letterSection clearLetterSectionAnimated:NO];
}

- (void) gameOver:(NSNotification*)notification
{
    LRGameScene *scene = (LRGameScene*)[self scene];
    scene.gameState = LRGameStateGameOver;

    self.gameIsOver = TRUE;
    
    NSLog(@"Game over");
    //Make all of the objects in the game non-touch responsive
    if (![[[notification userInfo] objectForKey:@"devpause"] isEqual: @(true)]) {
        [self _showGameOverLabel];

    }
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

- (void) pauseGame
{
    self.gameIsPaused = YES;
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

- (void) unpauseGame
{
    self.gameIsPaused = NO;
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

#pragma mark - Game State Properties

- (BOOL) isGameOver {
    return self.gameIsOver;
}

- (BOOL) isGamePaused {
    return self.gameIsPaused;
}

#pragma mark - Health Functions
- (CGFloat) percentHealth
{
    LRHealthSection *health = [[self.gameScene gamePlayLayer] healthSection];
    return [health percentHealth];    
}

- (void) moveHealthByPercent:(CGFloat)percent
{
    LRHealthSection *health = [[self.gameScene gamePlayLayer] healthSection];
    [health moveHealthByPercent:percent];
}

- (LRGameScene*)gameScene
{
    return (LRGameScene*)[self scene];
}

@end
