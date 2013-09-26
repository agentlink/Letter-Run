//
//  LRGamePlayLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGamePlayLayer.h"


@implementation LRGamePlayLayer

- (id) init
{
    if (self = [super init])
    {
        //Code here :)
        [self createLayerContent];        
    }
    return self;
}

- (void) createLayerContent
{
    self.healthSection = [[LRHealthSection alloc] initWithSize:CGSizeMake(self.size.width, 30)];
    self.healthSection.position = self.position;CGPointMake(0, self.position.y);
    [self addChild:self.healthSection];
}

@end
