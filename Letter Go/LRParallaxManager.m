//
//  LRParallaxManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRParallaxManager.h"
#import "LRGameStateManager.h"
#import "LRDifficultyManager.h"

@interface LRParallaxManager ()
@property (nonatomic) NSMutableArray *parallaxNodes;
@property NSTimeInterval initialTime;
@end

@implementation LRParallaxManager

# pragma mark - Set Up

- (id) init
{
    if (self = [super init])
    {
        self.initialTime = -1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unpauseGame) name:GAME_STATE_CONTINUE_GAME object:nil];

    }
    return self;
}

- (void) addParallaxNode:(LRParallaxNode *)node toIndex:(uint)index;
{
    node.relativeSpeed = [[[[LRDifficultyManager shared] parallaxLayerSpeeds] objectAtIndex:index] floatValue];
    NSAssert(node.relativeSpeed <= 1, @"Error: relative speed should be a value less than one");
    if (!self.parallaxNodes) self.parallaxNodes = [NSMutableArray arrayWithObject:node];
    else [self.parallaxNodes insertObject:node atIndex:index];
}

#pragma mark - Parallax Movement Functions
- (void) update:(NSTimeInterval)currentTime
{
    if ([[LRGameStateManager shared] isGameOver] || [[LRGameStateManager shared] isGamePaused]) {
        self.initialTime = -1;
        return;
    }
    else if (self.initialTime < 0) {
        self.initialTime = currentTime;
        return;
    }
    
    for (LRParallaxNode* node in self.parallaxNodes) {
        CGFloat distance = 0 - (currentTime - self.initialTime) * ([[LRDifficultyManager shared] parallaxSpeedFactor] * node.relativeSpeed);
        [node moveNodeBy:distance];
    }
    self.initialTime = currentTime;
}

#pragma mark - Node Access Methods

- (LRParallaxNode*) objectAtIndex:(NSUInteger)index {
    return [self.parallaxNodes objectAtIndex:index];
}

- (NSUInteger) count {
    return [self.parallaxNodes count];
}

#pragma mark - Game State Methods

- (void) unpauseGame {
    self.initialTime = -1;
}
@end
