//
//  LRParallaxManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGameStateDelegate.h"
#import "LRParallaxNode.h"

@interface LRParallaxManager : SKSpriteNode <LRGameStateDelegate>

enum {
    BackgroundIndex_Sky = 0,
    BackgroundIndex_Mountains,
    BackgroundIndex_Hills,
    BackgroundIndex_Grass
};

- (void)addParallaxNode:(LRParallaxNode *)node toIndex:(uint)index;

- (NSUInteger) count;

- (LRParallaxNode *)objectAtIndex:(NSUInteger)index;

@end
