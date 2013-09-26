//
//  LRBackgroundLayer.m
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRBackgroundLayer.h"

@interface LRBackgroundLayer ()

@property SKSpriteNode *backgroundImage;

@end

@implementation LRBackgroundLayer

- (id) init
{
    if (self = [super init])
    {
        [self createLayerContents];
    }
    return self;
}

- (void) createLayerContents
{
    self.backgroundImage = [[SKSpriteNode alloc] initWithColor:[SKColor colorWithRed:(132/255.0f) green:(227/255.0f) blue:(240/255.0f) alpha:1.0f] size:self.size];
    [self addChild:self.backgroundImage];
}

- (void) dealloc
{
    self.backgroundImage = nil;
}
@end
