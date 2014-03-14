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

+ (LRParallaxNode *)nodeWithImageNamed:(NSString *)imageName
{
    return [[LRParallaxNode alloc] initWithImageNamed:imageName];
}

- (id) initWithImageNamed:(NSString *)name
{
    if (self = [super init])
    {
        self.imageName = name;
        self.xOffset = 0;
        [self loadScrollingSprites];
    }
    return self;
}

- (void)loadScrollingSprites
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

- (SKSpriteNode *)repeatingSprite
{
    return [SKSpriteNode spriteNodeWithImageNamed:self.imageName];
}

#pragma mark - Movement Functions

- (void)moveNodeBy:(CGFloat)distance
{
    SKSpriteNode *sprite1 = [self.scrollingSprites objectAtIndex:0];
    SKSpriteNode *sprite2 = [self.scrollingSprites objectAtIndex:1];

    //Shift the sprites down
    sprite1.position = CGPointMake(sprite1.position.x + distance, sprite1.position.y);
    sprite2.position = CGPointMake(sprite2.position.x + distance, sprite2.position.y);
    
    //And if they have gone off screen, put them to the other side of the sprite that is still on screen
    if (sprite1.position.x < -sprite1.size.width) {
        sprite1.position = CGPointMake(sprite2.position.x + sprite1.size.width, sprite1.position.y);
    }
    if (sprite2.position.x < -sprite2.size.width) {
        sprite2.position = CGPointMake(sprite1.position.x + sprite2.size.width, sprite2.position.y);
    }
}

@end
