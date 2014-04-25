//
//  LRGameScene.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGameScene.h"
#import "LRCollisionManager.h"

#import "LRGameStateDelegate.h"
#import "LRGameStateManager.h"

static CGFloat const kLRGameSceneBlurEffectIntensity = 12.0;
static CGFloat const kLRGameSceneBlurEffectDuration = .4;

@interface LRGameScene ()
@property (nonatomic, weak) SKEffectNode *rootEffectNode;
@end

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

+ (SKEffectNode *)blurEffectNode
{
    SKEffectNode *node = [SKEffectNode node];
    [node setShouldEnableEffects:NO];
    CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", @1.0f, nil];
    [node setFilter:blur];
    return node;
}

- (void)didMoveToView:(SKView *)view
{
    [self setScaleMode:SKSceneScaleModeAspectFit];
    
    [self setUpPhysics];
    
    self.backgroundLayer = [[LRBackgroundLayer alloc] init];
    self.gamePlayLayer = [[LRGamePlayLayer alloc] init];
    
    //[self addChild:self.backgroundLayer];
    self.rootEffectNode = [LRGameScene blurEffectNode];
    [self.rootEffectNode addChild:self.backgroundLayer];
    [self.rootEffectNode addChild:self.gamePlayLayer];
    [self addChild:self.rootEffectNode];
}

- (void)setUpPhysics
{
    [self.physicsWorld setGravity: CGVectorMake(0.0, -6.3)];
    [self.physicsWorld setContactDelegate:[LRCollisionManager shared]];
}

- (void)setGameState:(LRGameState)gameState
{
    switch (gameState) {
        case LRGameStateNewGame:
            [self newGame];
            break;
        case LRGameStateGameOver:
            [self gameOver];
            break;
        default:
            break;
    }
    _gameState = gameState;
}

#pragma mark - LRGameStateDelegate methods

- (void)update:(NSTimeInterval)currentTime
{
    [self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node conformsToProtocol:@protocol(LRGameStateDelegate)])
        {
            SKNode <LRGameStateDelegate> *updatingNode = (SKNode <LRGameStateDelegate> *)node;
            if (self.gameState == LRGameStatePauseGame) {
                if ([updatingNode respondsToSelector:@selector(gameStatePaused:)])
                    [updatingNode gameStatePaused:currentTime];
            }
            else if (self.gameState == LRGameStateUnpauseGame) {
                if ([updatingNode respondsToSelector:@selector(gameStateUnpaused:)])
                    [updatingNode gameStateUnpaused:currentTime];
            }
            else if ([updatingNode respondsToSelector:@selector(update:)]) {
                [updatingNode update:currentTime];
            }
        }
    }];
    if (self.gameState == LRGameStateUnpauseGame) {
        self.gameState = LRGameStatePlaying;
    }
}

- (void)gameOver
{
    [self _sendAllNodesGameDelegateSelector:@selector(gameStateGameOver)];
}

- (void)newGame
{
    [self _sendAllNodesGameDelegateSelector:@selector(gameStateNewGame)];
}

- (void)_sendAllNodesGameDelegateSelector:(SEL)selector
{
    [self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node conformsToProtocol:@protocol(LRGameStateDelegate)])
        {
            SKNode <LRGameStateDelegate> *updatingNode = (SKNode <LRGameStateDelegate> *)node;
            if ([updatingNode respondsToSelector:selector] && selector) {
            
//                 NOTE: this is replacing the line below (and supressing a warning)
//                [updatingNode performSelector:selector];
//                 Article here: http://bit.ly/191N5Fh
                
                IMP imp = [updatingNode methodForSelector:selector];
                void (*func)(id, SEL) = (void *)imp;
                func(updatingNode, selector);
            }
        }
    }];

}

#pragma mark - Blur View
-(void)blurSceneWithCompletion:(void (^)())handler
{
    [[self rootEffectNode] setShouldRasterize:NO];
    [[self rootEffectNode] setShouldEnableEffects:YES];
    [[self rootEffectNode] runAction:[SKAction customActionWithDuration:kLRGameSceneBlurEffectDuration actionBlock:^(SKNode *node, CGFloat elapsedTime){
        NSNumber *radius = [NSNumber numberWithFloat:(elapsedTime/kLRGameSceneBlurEffectDuration) * kLRGameSceneBlurEffectIntensity];
        [[(SKEffectNode *)node filter] setValue:radius forKey:@"inputRadius"];
    }] completion:handler];
}

-(void)unblurSceneWithCompletion:(void (^)())handler
{
    [[self rootEffectNode] runAction:[SKAction customActionWithDuration:kLRGameSceneBlurEffectDuration actionBlock:^(SKNode *node, CGFloat elapsedTime){
        NSNumber *radius = [NSNumber numberWithFloat:(1 - elapsedTime/kLRGameSceneBlurEffectDuration) * kLRGameSceneBlurEffectIntensity];
        [[(SKEffectNode *)node filter] setValue:radius forKey:@"inputRadius"];
    }] completion:handler];

}
#pragma mark - Scene Getters
+ (LRGameScene *)scene
{
    return [[self alloc] init];
}

- (CGRect) window
{
    return self.frame;
}

@end
