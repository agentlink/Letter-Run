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

- (void) createSectionContent
{
    //The color will be replaced by a health bar sprite
    self.healthBar = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:self.size];
    //self.healthBar.position = CGPointMake(0 - self.size.width / 2, self.position.y);
    [self addChild:self.healthBar];
}

@end
