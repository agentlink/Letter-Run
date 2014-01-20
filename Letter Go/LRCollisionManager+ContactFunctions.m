//
//  LRCollisionManager+ContactFunctions.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/1/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRCollisionManager+ContactFunctions.h"

@implementation LRCollisionManager (ContactFunctions)

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    NSSet *nameSet = [NSSet setWithObjects:firstBody.node.name, secondBody.node.name, nil];
    if ([nameSet containsObject:NAME_SPRITE_FALLING_ENVELOPE])
    {
        //Code ;)
    }
}

@end
