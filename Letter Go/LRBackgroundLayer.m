//
//  LRBackgroundLayer.m
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRBackgroundLayer.h"
#import "LRParallaxNode.h"
#import "LRCloudLayer.h"
#import "LRGrassLayer.h"
#import "LRParallaxManager.h"

@interface LRBackgroundLayer ()
@property LRParallaxManager *parallaxManager;
@property NSMutableArray *backgroundLayers;
@end

enum {
    BackgroundIndex_Sky = 0,
    BackgroundIndex_Mountains,
    BackgroundIndex_Hills,
    BackgroundIndex_Grass
};

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
                                  toIndex:BackgroundIndex_Sky
                        withRelativeSpeed:1];
    [self.parallaxManager addParallaxNode:[LRParallaxNode nodeWithImageNamed:@"Background_Mountains.png"]
                                  toIndex:BackgroundIndex_Mountains
                        withRelativeSpeed:2];
    [self.parallaxManager addParallaxNode:[LRParallaxNode nodeWithImageNamed:@"Background_Hills.png"]
                                  toIndex:BackgroundIndex_Hills
                        withRelativeSpeed:3];
    [self.parallaxManager addParallaxNode:[[LRGrassLayer alloc] init]
                                  toIndex:BackgroundIndex_Grass
                        withRelativeSpeed:4];
    
    for (int i = 0; i < [self.parallaxManager count]; i++)
    {
        LRParallaxNode *layer = [self.parallaxManager objectAtIndex:i];
        [layer setScale:.5];
        if (i == BackgroundIndex_Hills)
            layer.position = CGPointMake(layer.position.x, [layer repeatingSprite].size.height/4 - self.size.height/2);
        else if (i == BackgroundIndex_Grass) {
            float grassOffset = -2;
            layer.position = CGPointMake(layer.position.x, [layer repeatingSprite].size.height/4 - self.size.height/2 + SIZE_HEIGHT_LETTER_SECTION + grassOffset );
            layer.zPosition += 20;
        }
        [self addChild:layer];
    }
    self.parallaxManager.speedFactor = 50;
}



@end
