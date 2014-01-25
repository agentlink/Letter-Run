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
#import "LRParallaxNode_SmallSprite.h"
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
        CGFloat backgroundHeight = SCREEN_HEIGHT - kSectionHeightLetterSection;
        CGFloat backgroundWidth = SCREEN_WIDTH;
        CGFloat backgroundXPos = self.size.width/2;
        CGFloat backgroundYPos = (SCREEN_HEIGHT + kSectionHeightLetterSection)/2;

        [self setSize:CGSizeMake(backgroundWidth, backgroundHeight)];
        [self setPosition:CGPointMake(backgroundXPos, backgroundYPos)];
        [self setUserInteractionEnabled:NO];
        
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
    [self.parallaxManager addParallaxNode:[LRParallaxNode nodeWithImageNamed:@"Background_Mountains.png"]
                                  toIndex:BackgroundIndex_Mountains];
    [self.parallaxManager addParallaxNode:[LRParallaxNode nodeWithImageNamed:@"Background_Hills.png"]
                                  toIndex:BackgroundIndex_Hills];
    [self.parallaxManager addParallaxNode:[LRParallaxNode_SmallSprite nodeWithImageNamed:@"Background_Grass2.png"]
                                  toIndex:BackgroundIndex_Grass];
    
    for (int i = 0; i < [self.parallaxManager count]; i++)
    {
        LRParallaxNode *layer = [self.parallaxManager objectAtIndex:i];
        [layer setScale:.5];
        CGFloat grassHeightOffset = -2;
        switch (i) {
            case BackgroundIndex_Sky:
                layer.zPosition = zPos_SkyLayer;
                break;
            case BackgroundIndex_Mountains:
                layer.zPosition = zPos_MountainLayer;
                break;
            case BackgroundIndex_Hills:
                layer.position = CGPointMake(layer.position.x, [layer repeatingSprite].size.height/4 - self.size.height/2);
                layer.zPosition = zPos_HillsLayer;
                break;
            case BackgroundIndex_Grass:
                layer.position = CGPointMake(layer.position.x, [layer repeatingSprite].size.height/4 - self.size.height/2 + kSectionHeightLetterSection + grassHeightOffset);
                layer.zPosition = zPos_GrassLayer;
                break;
            default:
                break;
        }
        [self addChild:layer];
    }
}



@end
