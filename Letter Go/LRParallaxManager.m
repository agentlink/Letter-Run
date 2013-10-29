//
//  LRParallaxManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRParallaxManager.h"

@interface LRParallaxManager ()
@property (nonatomic) NSMutableArray *parallaxNodes;
@end

@implementation LRParallaxManager

- (void) addParallaxNode:(LRParallaxNode *)node toIndex:(uint)index withRelativeSpeed: (CGFloat) relativeSpeed;
{
    node.relativeSpeed = relativeSpeed;
    
    if (!self.parallaxNodes) self.parallaxNodes = [NSMutableArray arrayWithObject:node];
    else [self.parallaxNodes insertObject:node atIndex:index];
}

- (void) sortParallaxNodes {
    [self.parallaxNodes sortUsingComparator:^NSComparisonResult(SKSpriteNode *node1, SKSpriteNode *node2) {
        if (node1.zPosition > node2.zPosition)
            return NSOrderedDescending;
        return NSOrderedAscending;
    }];
}

- (LRParallaxNode*) objectAtIndex:(NSUInteger)index {
    return [self.parallaxNodes objectAtIndex:index];
}

- (NSUInteger) count {
    return [self.parallaxNodes count];
}

- (void) update:(NSTimeInterval)currentTime
{
    
}

@end
