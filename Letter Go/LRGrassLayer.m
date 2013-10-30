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
        [self addGrassSprites];
    }
    return self;
}

- (void) addGrassSprites
{
    self.grassSpriteArray = [NSMutableArray array];
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

- (SKSpriteNode *)repeatingSprite
{
    return [SKSpriteNode spriteNodeWithImageNamed:@"Background_Grass.png"];
}

- (void) moveNodeBy:(CGFloat)distance
{
    BOOL swap = FALSE;
    for (SKSpriteNode *sprite in self.grassSpriteArray) {
        sprite.position = CGPointMake(sprite.position.x + distance, sprite.position.y);
        //If the sprite is off screen, move it to the back
        if (sprite == [self.grassSpriteArray objectAtIndex:0] &&
            sprite.position.x < 0 - self.scene.size.width - sprite.size.width/2)
        {
            SKSpriteNode *backSprite = [self.grassSpriteArray lastObject];
            sprite.position = CGPointMake(backSprite.position.x + sprite.size.width + self.offset, sprite.position.y);
            swap = TRUE;
        }
    }
    if (swap) {
        SKSpriteNode *frontGrass = [self.grassSpriteArray objectAtIndex:0];
        [self.grassSpriteArray removeObject:frontGrass];
        [self.grassSpriteArray addObject:frontGrass];
    }
    
}

@end
