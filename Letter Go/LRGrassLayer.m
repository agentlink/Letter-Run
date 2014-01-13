//
//  LRGrassLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGrassLayer.h"
#import "LRCollisionManager.h"
#import "LRFallingEnvelope.h"

@interface LRGrassLayer ()
@property NSMutableArray *grassSpriteArray;
@property NSMutableArray *envelopeArray;
@end

#define GRASS_FILE_NAME                     @"Background_Grass2.png"

@implementation LRGrassLayer

#pragma mark - Set Up/Initialization
- (id) init
{
    if (self = [super init])
    {
        self.size = CGSizeMake(SCREEN_WIDTH * 3, kParallaxHeightGrass);
        self.xOffset = 0;
        self.envelopeArray = [NSMutableArray array];
        
        [self addGrassSprites];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attachBlockToGrass:) name:NOTIFICATION_ENVELOPE_LANDED object:nil];

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
            sprite.position = CGPointMake(backSprite.position.x + sprite.size.width + self.xOffset, sprite.position.y);
            swapGrass = TRUE;
        }
    }
    /*
     TODO:
     Right now, a gap in the grass shows up from the first replacement.
     This is actually a deeper issue--the very first distance provided is
     six times higher than the next ones because the update loop hits a snag
     on its first run through (probably due to loading all the images
    */
    
    //Move envelopes
    NSMutableArray *envelopesToRemove = [NSMutableArray array];
    for (LRFallingEnvelope *envelope in self.envelopeArray) {
        if (envelope.blockState == BlockState_Landed) {
            envelope.position = CGPointMake(envelope.position.x + distance/2, envelope.position.y);
            if (envelope.position.x < 0 - SCREEN_WIDTH/2 - envelope.size.width/2) {
                [envelopesToRemove addObject:envelope];
            }
        }
    }
    
    if (swapGrass) {
        SKSpriteNode *frontGrass = [self.grassSpriteArray objectAtIndex:0];
        [self.grassSpriteArray removeObject:frontGrass];
        [self.grassSpriteArray addObject:frontGrass];
    }
    //Why are envelopes moving faster?
    [self.envelopeArray removeObjectsInArray:envelopesToRemove];
}

#pragma mark - Block Movement Functions

- (void) attachBlockToGrass:(NSNotification*)notification
{
    LRFallingEnvelope *envelope = [[notification userInfo] objectForKey:KEY_GET_LETTER_BLOCK];
    [self.envelopeArray addObject:envelope];
    //[envelope removePhysics];
}
@end
