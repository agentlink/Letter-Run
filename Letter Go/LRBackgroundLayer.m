//
//  LRBackgroundLayer.m
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRBackgroundLayer.h"
#import "LRParallaxNode.h"

@interface LRBackgroundLayer ()
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
    self.backgroundLayers = [[NSMutableArray alloc] init];
    [self.backgroundLayers setObject:[LRParallaxNode nodeWithImageNamed:@"Background_Sky.png"] atIndexedSubscript:BackgroundIndex_Sky];
    [self.backgroundLayers setObject:[LRParallaxNode nodeWithImageNamed:@"Background_Mountains.png"] atIndexedSubscript:BackgroundIndex_Mountains];
    [self.backgroundLayers setObject:[LRParallaxNode nodeWithImageNamed:@"Background_Hills.png"] atIndexedSubscript:BackgroundIndex_Hills];
    [self.backgroundLayers setObject:[LRParallaxNode nodeWithImageNamed:@"Background_Grass.png"] atIndexedSubscript:BackgroundIndex_Grass];
    
    for (int i = 0; i < [self.backgroundLayers count]; i++)
    {
        SKSpriteNode *layer = [self.backgroundLayers objectAtIndex:i];
        [layer setScale:.5];
        if (i == BackgroundIndex_Hills)
            layer.position = CGPointMake(layer.position.x, layer.size.height/2 - self.size.height/2);
        else if (i == BackgroundIndex_Grass) {
            layer.position = CGPointMake(layer.position.x, layer.size.height/2 - self.size.height/2 + SIZE_HEIGHT_LETTER_SECTION);
            layer.zPosition += 20;
        }

        [self addChild:layer];
    }
}

@end
