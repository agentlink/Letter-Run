//
//  LRBackgroundLayer.m
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRPositionConstants.h"
#import "LRBackgroundLayer.h"
#import "LRParallaxNode.h"
#import "LRCloudLayer.h"
#import "LRGrassLayer.h"
#import "LRParallaxManager.h"

@interface LRBackgroundLayer ()
@property LRParallaxManager *parallaxManager;
@property NSMutableArray *backgroundLayers;
@end

@implementation LRBackgroundLayer

- (id) init
{
    if (self = [super init])
    {
        self.name = NAME_LAYER_BACKGROUND;
        [self createLayerContents];
    }
    return self;
}

- (void) createLayerContents
{
    self.parallaxManager = [[LRParallaxManager alloc] init];
    [self addChild:self.parallaxManager];
    [self.parallaxManager addParallaxNode:[[LRCloudLayer alloc] init]
                                  toIndex:BackgroundIndex_Sky];
    [self.parallaxManager addParallaxNode:[LRParallaxNode nodeWithImageNamed:@"Background_Mountains2.png"]
                                  toIndex:BackgroundIndex_Mountains];
    [self.parallaxManager addParallaxNode:[LRParallaxNode nodeWithImageNamed:@"Background_Hills2.png"]
                                  toIndex:BackgroundIndex_Hills];
    [self.parallaxManager addParallaxNode:[[LRGrassLayer alloc] init]
                                  toIndex:BackgroundIndex_Grass];
    
    for (int i = 0; i < [self.parallaxManager count]; i++)
    {
        LRParallaxNode *layer = [self.parallaxManager objectAtIndex:i];
        [layer setScale:.5];
        CGFloat grassHeightOffset = -2;
        switch (i) {
            case BackgroundIndex_Sky:
                layer.yOffset = -5;
                layer.zPosition = zPos_SkyLayer;
                break;
            case BackgroundIndex_Mountains:
                layer.yOffset = -2;
                layer.zPosition = zPos_MountainLayer;
                break;
            case BackgroundIndex_Hills:
                layer.position = CGPointMake(layer.position.x, [layer repeatingSprite].size.height/4 - self.size.height/2);
                layer.yOffset = -10;
                layer.zPosition = zPos_HillsLayer;
                break;
            case BackgroundIndex_Grass:
                layer.position = CGPointMake(layer.position.x, [layer repeatingSprite].size.height/4 - self.size.height/2 + kSectionHeightLetterSection + grassHeightOffset);
                layer.zPosition = zPos_GrassLayer;
                layer.yOffset = -10;
                break;
            default:
                break;
        }
        [self addChild:layer];
    }
}



@end
