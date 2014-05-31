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
    
    SKEffectNode *effectNode = [LRGameScene blurEffectNode];
    [effectNode addChild:self.backgroundLayer];
    [effectNode addChild:self.gamePlayLayer];
    [self addChild:effectNode];
    self.rootEffectNode = effectNode;
    
    [self _addGameStateDelegateListeners];
}

- (void)setUpPhysics
{
    [self.physicsWorld setGravity: CGVectorMake(0.0, -6.3)];
    [self.physicsWorld setContactDelegate:[LRCollisionManager shared]];
}

- (void)_addGameStateDelegateListeners
{
    [self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node respondsToSelector:@selector(gameStateNewGame)]) {
            [[NSNotificationCenter defaultCenter] addObserver:node selector:@selector(gameStateNewGame) name:GAME_STATE_NEW_GAME object:nil];
        }
        if ([node respondsToSelector:@selector(gameStateGameOver)]) {
            [[NSNotificationCenter defaultCenter] addObserver:node selector:@selector(gameStateGameOver) name:GAME_STATE_GAME_OVER object:nil];
        }
    }];
}
#pragma mark - LRGameStateDelegate methods

- (void)update:(NSTimeInterval)currentTime
{
    for (NSString *nodeName in [LRGameScene _updateNodeNames]) {
        NSString *regex = [NSString stringWithFormat:@"//%@", nodeName];
        [self enumerateChildNodesWithName:regex usingBlock:^(SKNode *node, BOOL *stop) {
            if ([node conformsToProtocol:@protocol(LRGameStateDelegate)])
            {
                SKNode <LRGameStateDelegate> *updatingNode = (SKNode <LRGameStateDelegate> *)node;
                [updatingNode update:currentTime];
            }
        }];
    }
}

+ (NSArray *)_updateNodeNames
{
    return @[kLRGamePlayLayerLetterSectionName];
}

#pragma mark - Blur View
-(void)blurSceneWithCompletion:(void (^)())handler
{
    NSLog(@"Blur start time: %@", [NSDate date]);
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
    }] completion:^{
        [[self rootEffectNode] setShouldEnableEffects:NO];
        handler();
    }];
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
