//
//  LRGameScene.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGameScene.h"
#import "LRCollisionManager.h"

#import "LRObject.h"
#import "LRGameStateManager.h"

@implementation LRGameScene

#pragma mark - Initialization and Set Up
- (id) init
{
    //LRScenes are always initialized to the full size of the screen
    if (self = [super initWithSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)]) {
        [self addChild:[LRGameStateManager shared]];
    }
    return self;
}

- (void) didMoveToView:(SKView *)view
{
    [self setScaleMode:SKSceneScaleModeAspectFit];
    
    [self setUpPhysics];
    
    self.backgroundLayer = [[LRBackgroundLayer alloc] init];
    self.gamePlayLayer = [[LRGamePlayLayer alloc] init];
    
    //[self addChild:self.backgroundLayer];
    [self addChild:self.gamePlayLayer];
}

- (void) setUpPhysics
{
    [self.physicsWorld setGravity: CGVectorMake(0.0, -5.3)];
    [self.physicsWorld setContactDelegate:[LRCollisionManager shared]];
}

#pragma mark - Run Loop Functions

- (void) update:(NSTimeInterval)currentTime
{
    for (SKSpriteNode *child in [self children])
    {
        if ([child isKindOfClass:[LRObject class]])
        {
            [(LRObject*)child update:currentTime];
        }
    }
}

#pragma mark - Scene Getters
+ (LRGameScene*) scene
{
    return [[self alloc] init];
}

- (CGRect) window
{
    return self.frame;
}

@end
