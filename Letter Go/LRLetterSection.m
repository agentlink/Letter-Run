//
//  LRLetterSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSection.h"

@interface LRLetterSection ()
@property SKSpriteNode *letterSection;
@end

@implementation LRLetterSection

- (void) createSectionContent
{
    //The color will be replaced by a health bar sprite
    self.letterSection = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:self.size];
//    self.letterSection.position = CGPointMake(0 - self.size.width / 2, self.position.y);
    [self addChild:self.letterSection];
}

@end
