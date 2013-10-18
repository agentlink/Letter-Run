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
    BackgroundLayer_Sky = 0,
    BackgroundLayer_Hills
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
    [self.backgroundLayers setObject:[SKSpriteNode spriteNodeWithImageNamed:@"Background_Sky.jpg"] atIndexedSubscript:BackgroundLayer_Sky];
    //[self.backgroundLayers setObject:[SKSpriteNode spriteNodeWithImageNamed:@"Background_Hills.jpg"] atIndexedSubscript:BackgroundLayer_Hills];
    
    for (SKSpriteNode *layer in self.backgroundLayers) {
        [self addChild:layer];
    }
}

@end
