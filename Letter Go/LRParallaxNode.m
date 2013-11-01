//
//  LRParallaxNode.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRParallaxNode.h"

@interface LRParallaxNode ()

@property NSString *imageName;
@property NSMutableArray *scrollingSprites;

@end

@implementation LRParallaxNode

#pragma mark - Initialization + Set Up Functions

+ (LRParallaxNode*) nodeWithImageNamed:(NSString*)imageName
{
    return [[LRParallaxNode alloc] initWithImageNamed:imageName];
}

- (id) initWithImageNamed:(NSString *)name
{
    if (self = [super init])
    {
        self.imageName = name;
        self.yOffset = 0;
        [self loadScrollingSprites];
    }
    return self;
}

- (void) loadScrollingSprites
{
    self.scrollingSprites = [[NSMutableArray alloc] init];
    SKSpriteNode *firstFrame = [self repeatingSprite];
    [self addChild:firstFrame];
    [self.scrollingSprites addObject:firstFrame];
    
    SKSpriteNode *secondFrame = [self repeatingSprite];
    secondFrame.position = CGPointMake(firstFrame.position.x + firstFrame.size.width, firstFrame.position.y);
    [self addChild:secondFrame];
    [self.scrollingSprites addObject:secondFrame];
}

- (SKSpriteNode*) repeatingSprite
{
    return [SKSpriteNode spriteNodeWithImageNamed:self.imageName];
}

#pragma mark - Movement Functions

- (void) moveNodeBy:(CGFloat)distance
{
    BOOL swap = FALSE;
    for (SKSpriteNode *sprite in self.scrollingSprites) {
        sprite.position = CGPointMake(sprite.position.x + distance, sprite.position.y);
        //If the sprite is off screen, move it to the back
        if (sprite == [self.scrollingSprites objectAtIndex:0] &&
            sprite.position.x < 0 - self.scene.size.width - sprite.size.width/2)
        {
            SKSpriteNode *secondSprite = [self.scrollingSprites objectAtIndex:1];
            sprite.position = CGPointMake(secondSprite.position.x + sprite.size.width + self.yOffset, sprite.position.y);
            swap = TRUE;
        }
    }
    if (swap) [self.scrollingSprites exchangeObjectAtIndex:0 withObjectAtIndex:1];
}

@end
