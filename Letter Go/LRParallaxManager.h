//
//  LRParallaxManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRObject.h"
#import "LRParallaxNode.h"
@interface LRParallaxManager : LRObject

- (void) addParallaxNode:(LRParallaxNode *)node toIndex:(uint)index withRelativeSpeed: (CGFloat) relativeSpeed;

- (NSUInteger) count;
- (LRParallaxNode*) objectAtIndex:(NSUInteger)index;

@property CGFloat speedFactor;

@end
