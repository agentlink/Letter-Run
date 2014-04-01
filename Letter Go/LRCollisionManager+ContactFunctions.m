//
//  LRCollisionManager+ContactFunctions.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/1/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRCollisionManager+ContactFunctions.h"
#import "LRCollectedEnvelope.h"

typedef NS_ENUM(NSUInteger, LRCollisionType)
{
    kLRCollision_Undefined = 0,
    kLRCollision_BottomBarrier_SectionBlock,
};

@implementation LRCollisionManager (ContactFunctions)

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA.node;
        secondBody = contact.bodyB.node;
    }
    else {
        firstBody = contact.bodyB.node;
        secondBody = contact.bodyA.node;
    }
}

- (LRCollisionType) collisionTypeForNode:(SKNode *)nodeA andNode:(SKNode *)nodeB
{
    return kLRCollision_Undefined;
}

@end
