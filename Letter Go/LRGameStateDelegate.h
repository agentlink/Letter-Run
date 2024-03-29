//
//  LRGameStateDelegate.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/30/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, LRGameState)
{
    LRGameStateNewGame,
    LRGameStateGameOver,
    LRGameStatePauseGame,
    LRGameStateUnpauseGame,
    LRGameStatePlaying
};

@protocol LRGameStateDelegate <NSObject>
@optional
///Called when the game is over
- (void)gameStateGameOver;
///Called when a new game begins
- (void)gameStateNewGame;
/*!
 @description Called every time the game loop runs
 @param currentTime The interval that the game loop is currently on
 */
- (void)update:(NSTimeInterval)currentTime;
@end