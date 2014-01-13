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
#import "LRDifficultyManager.h"

@interface LRGrassLayer ()
@property (nonatomic) NSMutableArray *grassSpriteArray;
@property (nonatomic) NSMutableArray *envelopeArray;
@property SKSpriteNode *backSprite;
@property BOOL lettersFallVertically;

@end

static CGFloat const kGrassXOffset      =       -10;
static NSString* const kGrassFileName   =       @"Background_Grass2.png";

@implementation LRGrassLayer
@synthesize lettersFallVertically;
#pragma mark - Set Up/Initialization

- (id) init
{
    if (self = [super init])
    {
        self.size = CGSizeMake(SCREEN_WIDTH * 3, kParallaxHeightGrass);
        self.xOffset = -8;
        lettersFallVertically = [[LRDifficultyManager shared] lettersFallVertically];
        //Add the grass sprites to the screen
        for (SKSpriteNode *grassBlock in self.grassSpriteArray) {
            [self addChild:grassBlock];
        }
        self.backSprite = [self.grassSpriteArray lastObject];
        
        
        //If the letters fall vertically, look to attach
        if (lettersFallVertically) {
        }

    }
    return self;
}

- (NSMutableArray*) grassSpriteArray
{
    if (!_grassSpriteArray) {
        NSUInteger grassSpriteCount = [self grassSpriteCount];
        CGFloat grassWidth = [self grassImageWidth];
        CGFloat grassXPos = 0 - self.size.width/2 + grassWidth;
        
        _grassSpriteArray = [[NSMutableArray alloc] initWithCapacity:grassSpriteCount];
        for (int i = 0; i < grassSpriteCount; i++) {
            SKSpriteNode *grassBlock = [self repeatingSprite];
            grassBlock.position = CGPointMake(grassXPos, 0);
            grassXPos += grassWidth;
            [_grassSpriteArray addObject:grassBlock];
        }
    }
    return  _grassSpriteArray;
}

- (NSMutableArray*) envelopeArray
{
    if (!lettersFallVertically) {
        _envelopeArray = nil;
    }
    else if (!_envelopeArray) {
        _envelopeArray = [NSMutableArray new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attachBlockToGrass:) name:NOTIFICATION_ENVELOPE_LANDED object:nil];
    }
    return _envelopeArray;
}

///Returns the number of grass sprites that have to be loaded
- (NSUInteger) grassSpriteCount {
    float grassWidth = [self grassImageWidth];
    NSUInteger numGrassBlocks = self.size.width/grassWidth + 1;
    return numGrassBlocks;
}

- (CGFloat) grassImageWidth {
    SKSpriteNode *grassImage = [self repeatingSprite];
    return grassImage.size.width;
}


#pragma mark - Movement Functions

- (SKSpriteNode *)repeatingSprite
{
    return [SKSpriteNode spriteNodeWithImageNamed:kGrassFileName];
}

- (void) moveNodeBy:(CGFloat)distance
{
    [self moveGrassByDistance:distance];
    if (self.envelopeArray) {
        [self moveEnvelopesByDistance:distance];
    }
    
}
///Moves the grass sprites
- (void) moveGrassByDistance:(CGFloat)distance
{
    for (SKSpriteNode *sprite in self.grassSpriteArray) {
        //Shift the grass down by the distance
        sprite.position = CGPointMake(sprite.position.x + distance, sprite.position.y);
        //If the sprite is off screen, move it to the back
        if (sprite.position.x < 0 - self.scene.size.width - sprite.size.width/2)
        {
            sprite.position = CGPointMake(self.backSprite.position.x + sprite.size.width + self.xOffset,
                                          sprite.position.y);
            self.backSprite = sprite;
        }
    }
}

///Moves the envelopes on the ground with the grass sprites
- (void) moveEnvelopesByDistance:(CGFloat)distance
{
    /*
     TODO: Refactor this function so that it doesn't need to check for the ENVELOPE_LANDED notification
     and check wheather or not the block is in BlockState_Landed. This should be centralized
     */
    NSMutableArray *envelopesToRemove = [NSMutableArray array];
    for (LRFallingEnvelope *envelope in self.envelopeArray) {
        if (envelope.blockState == BlockState_Landed) {
            //Why does this have to be distance/2?
            envelope.position = CGPointMake(envelope.position.x + distance/2, envelope.position.y);
            if (envelope.position.x < 0 - SCREEN_WIDTH/2 - envelope.size.width/2) {
                [envelopesToRemove addObject:envelope];
            }
        }
    }
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
