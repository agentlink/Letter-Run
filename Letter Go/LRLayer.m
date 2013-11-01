//
//  LRLayer.m
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLayer.h"

@implementation LRLayer
- (id) init
{
    if (self = [super init])
    {
        //Layers should all be full screen and in the center
        [self setSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self setPosition:CGPointMake(self.size.width/2, self.size.height/2)];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

@end
