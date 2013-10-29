//
//  LRGrassLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGrassLayer.h"

@interface LRGrassLayer ()
@property NSMutableArray *grassSpriteArray;
@end

@implementation LRGrassLayer

- (id) init
{
    if (self = [super init])
    {
        SKSpriteNode *tempGrassBlock = [SKSpriteNode spriteNodeWithImageNamed:@"Background_Grass.png"];
        self.size = CGSizeMake([[UIScreen mainScreen] bounds].size.width * 4, tempGrassBlock.size.height);
        NSLog(@"Width : %f", self.size.width);
        [self addGrassSprites];
    }
    return self;
}

- (void) addGrassSprites
{
    SKSpriteNode *tempGrassBlock = [SKSpriteNode spriteNodeWithImageNamed:@"Background_Grass.png"];
    int numGrassBlocks = self.size.width / tempGrassBlock.size.width + 1;
    CGFloat xPos = 0 - self.size.width/2 + tempGrassBlock.size.width/2;
    for (int i = 0; i < numGrassBlocks; i++)
    {
        SKSpriteNode *grassBlock = [SKSpriteNode spriteNodeWithImageNamed:@"Background_Grass.png"];
        grassBlock.position = CGPointMake(xPos, 0);
        [self addChild:grassBlock];
        [self.grassSpriteArray addObject:grassBlock];
        xPos += grassBlock.size.width;
    }
}

@end
