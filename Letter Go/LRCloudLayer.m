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
    if (self = [super initWithColor:
                [SKColor colorWithRed:174.0/255.0 green:227.0/255.0 blue:248.0/255.0 alpha:1]
                               size:CGSizeMake([UIScreen mainScreen].bounds.size.height * 2, [UIScreen mainScreen].bounds.size.width * 2)])
    {
        [self addRandomClouds];
    }
    return self;
}

- (void) addRandomClouds
{
    SKSpriteNode *tempCloud = [SKSpriteNode spriteNodeWithImageNamed:@"Background_Cloud.png"];
    int numClouds = 2;
    //Must be at least two thirds of the screen high
    float minHeight = self.size.height/6;
    float maxHeight = self.size.height/2 - tempCloud.size.height/2;
    float minWidth = tempCloud.size.width/2 - self.size.width/2;
    float maxWidth = 0 - minWidth;
    for (int i = 0; i < numClouds; i++) {
        SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"Background_Cloud.png"];
        cloud.position = CGPointMake(skRand(minWidth, maxWidth), skRand(minHeight, maxHeight));
        NSLog(@"Position for Cloud %i: (%f, %f)", i, cloud.position.x, cloud.position.y);
        [self addChild:cloud];
    }
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return (arc4random()%(int)(high - low)) + low;
}

@end
