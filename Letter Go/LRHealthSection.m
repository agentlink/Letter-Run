//
//  LRHealthSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRHealthSection.h"

@interface LRHealthSection ()
@property SKSpriteNode *healthBar;
@end

@implementation LRHealthSection

- (id) init
{
    NSAssert(0, @"Error: must initialize LRHealthSection with initWithSize");
    return nil;
}

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithColor:[SKColor clearColor] size:size])
    {
        //The color will be replaced by a health bar sprite
        self.healthBar = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:size];
        self.healthBar.position = CGPointMake(0 - self.size.width / 2, self.position.y);
        [self addChild:self.healthBar];
    }
    return self;
}



@end
