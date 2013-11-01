//
//  LRCloudLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRCloudLayer.h"

@implementation LRCloudLayer

- (id) init
{
    if (self = [super initWithImageNamed:@""]) {
        
    }
    return self;
}

- (SKSpriteNode *) repeatingSprite
{
    SKSpriteNode *repeatingSprite = [[SKSpriteNode alloc]
                                     initWithColor:[SKColor colorWithRed:174.0/255.0 green:227.0/255.0 blue:248.0/255.0 alpha:1]
                                     size:CGSizeMake(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 3)];
    //Add clouds to the sprite
    SKSpriteNode *tempCloud = [SKSpriteNode spriteNodeWithImageNamed:@"Background_Cloud.png"];
    int numClouds = 2;
    //Must be at least two thirds of the screen high
    float minHeight = repeatingSprite.size.height/6;
    float maxHeight = repeatingSprite.size.height/2 - tempCloud.size.height/2;
    float minWidth = tempCloud.size.width/2 - repeatingSprite.size.width/2;
    float maxWidth = repeatingSprite.size.width/2 - tempCloud.size.width/2;
    //TODO: Make cloud generation semi random, not totally random
    for (int i = 0; i < numClouds; i++) {
        SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"Background_Cloud.png"];
        cloud.position = CGPointMake(skRand(minWidth, maxWidth), skRand(minHeight, maxHeight));
        [repeatingSprite addChild:cloud];
    }
    return repeatingSprite;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return ((arc4random()%(int)(high - low)) + low);
}

@end
