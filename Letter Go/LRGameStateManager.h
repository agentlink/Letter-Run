//
//  LRGameStateManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/4/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRGameStateDelegate.h"
#import "LRGameScene.h"

@interface LRGameStateManager : SKNode

@property (nonatomic, readonly) NSDictionary *letterProbabilities;

+ (LRGameStateManager*) shared;
- (LRGameScene*)gameScene;

- (BOOL) isGameOver;
- (BOOL) isGamePaused;

@end