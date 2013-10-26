//
//  LRBackgroundLayer.m
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRBackgroundLayer.h"

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
    [self.backgroundLayers setObject:[SKSpriteNode spriteNodeWithImageNamed:@"Background_Sky.png"] atIndexedSubscript:BackgroundIndex_Sky];
    [self.backgroundLayers setObject:[SKSpriteNode spriteNodeWithImageNamed:@"Background_Mountains.png"] atIndexedSubscript:BackgroundIndex_Mountains];
    [self.backgroundLayers setObject:[SKSpriteNode spriteNodeWithImageNamed:@"Background_Hills.png"] atIndexedSubscript:BackgroundIndex_Hills];
    
    for (int i = 0; i < [self.backgroundLayers count]; i++)
    {
        SKSpriteNode *layer = [self.backgroundLayers objectAtIndex:i];
        [layer setScale:.5];
        if (i == BackgroundIndex_Hills)
            layer.position = CGPointMake(layer.position.x, layer.size.height/2 - self.size.height/2);
        [self addChild:layer];
    }
}

@end
