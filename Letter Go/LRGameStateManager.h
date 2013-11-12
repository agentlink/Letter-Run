//
//  LRGameStateManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/4/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRGameStateManager : SKNode

@property (nonatomic, readonly) NSDictionary *letterProbabilities;

+ (LRGameStateManager*) shared;
- (BOOL) isLetterSectionFull;
- (BOOL) isGameOver;
- (BOOL) isGamePaused;

- (CGFloat) percentHealth;
- (void) moveHealthByPercent:(CGFloat)percent;

@end
