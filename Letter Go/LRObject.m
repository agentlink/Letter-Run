//
//  LRObject.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/30/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRObject.h"

@implementation LRObject

- (void) update:(NSTimeInterval)currentTime
{
    for (SKSpriteNode *child in [self children])
    {
        if ([child isKindOfClass:[LRObject class]])
        {
            [(LRObject*)child update:currentTime];
        }
    }
}
@end
