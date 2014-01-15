//
//  LRParallaxNode_SmallSprite.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRParallaxNode_SmallSprite.h"
#import "LRCollisionManager.h"
#import "LRFallingEnvelope.h"
#import "LRDifficultyManager.h"

@interface LRParallaxNode_SmallSprite ()

@property (nonatomic) NSString *fileName;
@property (nonatomic) NSMutableArray *spriteArray;
@property SKSpriteNode *backSprite;

@end

@implementation LRParallaxNode_SmallSprite

#pragma mark - Set Up/Initialization

+ (LRParallaxNode_SmallSprite*) nodeWithImageNamed:(NSString*)imageName
{
    return [[LRParallaxNode_SmallSprite alloc] initWithImageNamed:imageName];
}

- (id) initWithImageNamed:(NSString *)name
{
    if (self = [super init]) {
        self.fileName = name;
        self.xOffset = 0;
        self.size = [self nodeSize];
        
        //Add the sprites to the screen
        for (SKSpriteNode *grassBlock in self.spriteArray) {
            [self addChild:grassBlock];
        }
        self.backSprite = [self.spriteArray lastObject];        
    }
    return self;
}


- (id) init
{
    if (self = [super init])
    {
        self.size = CGSizeMake(SCREEN_WIDTH * 3, kParallaxHeightGrass);
        self.xOffset = -8;
        //Add the sprites to the screen
        for (SKSpriteNode *grassBlock in self.spriteArray) {
            [self addChild:grassBlock];
        }
        self.backSprite = [self.spriteArray lastObject];
    }
    return self;
}

- (NSMutableArray*) spriteArray
{
    if (!_spriteArray) {
        NSUInteger spriteCount = [self spriteCount];
        CGFloat spriteWidth = [self spriteWidth];
        CGFloat xPos = 0 - self.size.width/2 + spriteWidth;
        
        _spriteArray = [[NSMutableArray alloc] initWithCapacity:spriteCount];
        for (int i = 0; i < spriteCount; i++) {
            SKSpriteNode *repeatingSprite = [self repeatingSprite];
            repeatingSprite.position = CGPointMake(xPos, 0);
            xPos += spriteWidth;
            [_spriteArray addObject:repeatingSprite];
        }
    }
    return  _spriteArray;
}

- (CGSize) nodeSize {
    CGFloat width = SCREEN_WIDTH * 3;
    CGFloat height = [self repeatingSprite].size.height;
    return  CGSizeMake(width, height);
}


///Returns the number of grass sprites that have to be loaded
- (NSUInteger) spriteCount {
    float spriteWidth = [self spriteWidth];
    NSUInteger numSprites = self.size.width/spriteWidth + 1;
    return numSprites;
}

- (CGFloat) spriteWidth {
    SKSpriteNode *sprite = [self repeatingSprite];
    return sprite.size.width;
}

- (SKSpriteNode *)repeatingSprite
{
    return [SKSpriteNode spriteNodeWithImageNamed:self.fileName];
}


#pragma mark - Movement Functions


- (void) moveNodeBy:(CGFloat)distance
{
    for (SKSpriteNode *sprite in self.spriteArray) {
        //Shift each sprite down by the distance
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


@end
