//
//  LRParallaxNode.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRParallaxNode.h"

@implementation LRParallaxNode

+ (LRParallaxNode*) nodeWithImageNamed:(NSString*)imageName
{
    return [[LRParallaxNode alloc] initWithImageNamed:imageName];
}

- (id) initWithImageNamed:(NSString *)name
{
    if (self = [super initWithImageNamed:name])
    {
        
    }
    return self;
}
@end
