//
//  LRGrassLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGrassLayer.h"
#import "LRCollisionManager.h"

@interface LRGrassLayer ()
@property NSMutableArray *grassSpriteArray;
@property NSMutableArray *edgeArray;
@end

#define GRASS_FILE_NAME                     @"Background_Grass.png"

@implementation LRGrassLayer

#pragma mark - Set Up/Initialization
- (id) init
{
    if (self = [super init])
    {
        SKSpriteNode *tempGrassBlock = [SKSpriteNode spriteNodeWithImageNamed:GRASS_FILE_NAME];
        self.size = CGSizeMake(SCREEN_WIDTH * 3, tempGrassBlock.size.height);
        self.yOffset = 0;
        [self addGrassSprites];
        [self setUpPhysics];

    }
    return self;
}

- (void) addGrassSprites
{
    self.grassSpriteArray = [NSMutableArray array];
    SKSpriteNode *tempGrassBlock = [SKSpriteNode spriteNodeWithImageNamed:GRASS_FILE_NAME];
    int numGrassBlocks = self.size.width / tempGrassBlock.size.width + 1;
    CGFloat xPos = 0 - self.size.width/2 + tempGrassBlock.size.width/2;
    for (int i = 0; i < numGrassBlocks; i++)
    {
        SKSpriteNode *grassBlock = [SKSpriteNode spriteNodeWithImageNamed:GRASS_FILE_NAME];
        grassBlock.position = CGPointMake(xPos, 0);
        [self addChild:grassBlock];
        [self.grassSpriteArray addObject:grassBlock];
        xPos += grassBlock.size.width;
    }
}

- (void) setUpPhysics
{
    self.edgeArray = [NSMutableArray array];
    
    SKSpriteNode *tempGrass = [self.grassSpriteArray objectAtIndex:0];
    float yPos = tempGrass.position.y - tempGrass.size.height/2;
    CGPoint leftScreen = CGPointMake(0 - self.size.width /2, 0);
    CGPoint midScreen = CGPointMake (self.size.width/2, 0);
    
    for (int i = 0; i < 2; i ++) {
//        UIColor *color = [UIColor clearColor];
        UIColor *color = (i == 0) ? [UIColor redColor] : [UIColor blackColor];
        SKSpriteNode *bottomEdgeSprite = [[SKSpriteNode alloc] initWithColor:color size:CGSizeMake(self.size.width, 1)];
        bottomEdgeSprite.name = NAME_SPRITE_BOTTOM_EDGE;
        bottomEdgeSprite.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:leftScreen toPoint:midScreen];
        
        bottomEdgeSprite.position = CGPointMake(i * self.size.width, yPos);
        
        [[LRCollisionManager shared] setBitMasksForSprite:bottomEdgeSprite];
        [self.edgeArray addObject:bottomEdgeSprite];
        [self addChild:bottomEdgeSprite];

    }
    //CGPoint rightScreen = CGPointMake(self.size.width * 1.5, yPos);
    /*
     SKPhysicsBody *bottomEdgeL = [SKPhysicsBody bodyWithEdgeFromPoint:leftScreen toPoint:midScreen];
     SKSpriteNode *bottomEdgeLSprite = [[SKSpriteNode alloc] init];
     bottomEdgeLSprite.physicsBody = bottomEdgeL;
     bottomEdgeLSprite.position = CGPointMake(self.position.x, yPos);
     bottomEdgeLSprite.name = NAME_SPRITE_BOTTOM_EDGE;
     [self.edgeArray addObject:bottomEdgeLSprite];
     
     SKPhysicsBody *bottomEdgeR = [SKPhysicsBody bodyWithEdgeFromPoint:midScreen toPoint:rightScreen];
     SKSpriteNode *bottomEdgeRSprite = [[SKSpriteNode alloc] init];
     bottomEdgeRSprite.physicsBody = bottomEdgeR;
     bottomEdgeRSprite.position = CGPointMake(self.position.x + self.size.width, yPos);
     [self.edgeArray addObject:bottomEdgeRSprite];
     bottomEdgeRSprite.name = NAME_SPRITE_BOTTOM_EDGE;
     */

}

#pragma mark - Movement Functions

- (SKSpriteNode *)repeatingSprite
{
    return [SKSpriteNode spriteNodeWithImageNamed:GRASS_FILE_NAME];
}

- (void) moveNodeBy:(CGFloat)distance
{
    //Moving grass
    BOOL swapGrass = FALSE;
    for (SKSpriteNode *sprite in self.grassSpriteArray) {
        sprite.position = CGPointMake(sprite.position.x + distance, sprite.position.y);
        //If the sprite is off screen, move it to the back
        if (sprite == [self.grassSpriteArray objectAtIndex:0] &&
            sprite.position.x < 0 - self.scene.size.width - sprite.size.width/2)
        {
            SKSpriteNode *backSprite = [self.grassSpriteArray lastObject];
            sprite.position = CGPointMake(backSprite.position.x + sprite.size.width + self.yOffset, sprite.position.y);
            swapGrass = TRUE;
        }
    }
    /*
     TODO
     Right now, a gap in the grass shows up from the first replacement.
     This is actually a deeper issue--the very first distance provided is
     six times higher than the next ones because the update loop hits a snag
     on its first run through (probably due to loading all the images
    */
    if (swapGrass) {
        SKSpriteNode *frontGrass = [self.grassSpriteArray objectAtIndex:0];
        [self.grassSpriteArray removeObject:frontGrass];
        [self.grassSpriteArray addObject:frontGrass];
    }
    
    //Moving bottom edges
    BOOL swapEdge;
    for (SKSpriteNode *sprite in self.edgeArray) {
        sprite.position = CGPointMake(sprite.position.x + distance, sprite.position.y);
        if (sprite == [self.self.edgeArray objectAtIndex:0] &&
            sprite.position.x < 0 - self.scene.size.width - sprite.size.width/2)
        {
            SKSpriteNode *secondSprite = [self.edgeArray objectAtIndex:1];
            sprite.position = CGPointMake(secondSprite.position.x + sprite.size.width + self.yOffset, sprite.position.y);
            swapEdge = TRUE;
        }
    }
    if (swapEdge) [self.edgeArray exchangeObjectAtIndex:0 withObjectAtIndex:1];
}

@end
