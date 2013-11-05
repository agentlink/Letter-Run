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

@interface LRGameStateManager ()
@property BOOL gameIsOver;
@property BOOL gameIsPaused;
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
        [self setUpNotifications];
    }
    return self;
}

- (void) setUpNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:GAME_STATE_GAME_OVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseGame) name:GAME_STATE_PAUSE_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unpauseGame) name:GAME_STATE_CONTINUE_GAME object:nil];
}

- (BOOL) isLetterSectionFull
{
    LRLetterSection *letterSection = [[(LRGameScene*)self.scene gamePlayLayer] letterSection];
    return ([letterSection numLettersInSection] == LETTER_CAPACITY);
}

#pragma mark - Game State Functions

- (void) newGame
{
    LRGamePlayLayer *gpl = [(LRGameScene*)[self scene] gamePlayLayer];
    [self clearBoard];
    [[LRDifficultyManager shared] resetLevel];
    self.gameIsOver = FALSE;
    self.gameIsPaused = FALSE;
    [gpl.pauseButton setIsEnabled:YES];
    [gpl dropInitialLetters];
}

- (void) clearBoard
{
    [self setGameBoardObjectTouchability:YES];
    LRGamePlayLayer *gpl = [(LRGameScene*)[self scene] gamePlayLayer];

    //Remove all envelopes
    NSMutableArray *fallingEnvelopeArray = [NSMutableArray array];
    for (SKNode *child in [gpl children])
    {
        if ([child.name isEqualToString:NAME_SPRITE_FALLING_ENVELOPE])
            [fallingEnvelopeArray addObject:child];
    }
    [gpl removeChildrenInArray:fallingEnvelopeArray];
    
    //Clear the letter section
    [[gpl letterSection] clearLetterSection];
    
}

- (void) gameOver
{
    self.gameIsOver = TRUE;
    NSLog(@"Game over");
    //Make all of the objects in the game non-touch responsive
    [self setGameBoardObjectTouchability:FALSE];

    SKLabelNode *gameOverLabel = [[SKLabelNode alloc] init];
    gameOverLabel.text = @"Game Over";
    gameOverLabel.fontColor = [SKColor redColor];
    gameOverLabel.fontSize = 50;
    __block LRGamePlayLayer *gpl = [(LRGameScene*)[self scene] gamePlayLayer];
    
    [gpl.pauseButton setIsEnabled:NO];
    [gpl removeAllActions];

    
    
    SKAction *showLabel = [SKAction runBlock:^{
        [gpl addChild:gameOverLabel];
    }];
    SKAction *delay = [SKAction waitForDuration:3.5];
    SKAction *restartLevel = [SKAction runBlock:^{
        [gpl removeChildrenInArray:[NSArray arrayWithObject:gameOverLabel]];
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_NEW_GAME object:self];
        [self newGame];
    }];
    [self runAction:[SKAction sequence:@[showLabel, delay, restartLevel]]];
    
    
}

- (void) pauseGame
{
    self.gameIsPaused = YES;
    LRGamePlayLayer *gpl = [(LRGameScene*)[self scene] gamePlayLayer];
    gpl.paused = YES;
    [gpl enumerateChildNodesWithName:NAME_SPRITE_FALLING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        [node setUserInteractionEnabled:NO];
        [[node actionForKey:ACTION_DROP_ENVELOPE] setSpeed:0];
    }];
    [[gpl actionForKey:ACTION_ENVELOPE_LOOP] setSpeed:0];
    [gpl.letterSection setUserInteractionEnabled:NO];

}

- (void) unpauseGame
{
    self.gameIsPaused = NO;
    LRGamePlayLayer *gpl = [(LRGameScene*)[self scene] gamePlayLayer];
    gpl.paused = NO;
    [gpl enumerateChildNodesWithName:NAME_SPRITE_FALLING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        [node setUserInteractionEnabled:YES];
        [[node actionForKey:ACTION_DROP_ENVELOPE] setSpeed:1];
    }];
    [[gpl actionForKey:ACTION_ENVELOPE_LOOP] setSpeed:1];
    [gpl.letterSection setUserInteractionEnabled:YES];

}

- (void)setGameBoardObjectTouchability:(BOOL)value
{
    LRGamePlayLayer *gpl = [(LRGameScene*)[self scene] gamePlayLayer];
    [gpl enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
        node.userInteractionEnabled = value;
    }];
}

- (BOOL) isGameOver {
    return self.gameIsOver;
}

- (BOOL) isGamePaused {
    return self.gameIsPaused;
}
@end
