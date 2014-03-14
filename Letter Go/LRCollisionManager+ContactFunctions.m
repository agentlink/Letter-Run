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
    LRCollisionType collisionType = [self collisionTypeForNode:firstBody andNode:secondBody];
    if (collisionType == kLRCollision_BottomBarrier_SectionBlock) {
        LRCollectedEnvelope *envelope = (LRCollectedEnvelope *)secondBody;
        [envelope envelopeHitBottomBarrier];
    }
}

- (LRCollisionType) collisionTypeForNode:(SKNode *)nodeA andNode:(SKNode *)nodeB
{
    if ([nodeA.name isEqualToString:NAME_SPRITE_BOTTOM_BARRIER] &&
        [nodeB.name rangeOfString:NAME_SPRITE_SECTION_LETTER_BLOCK].location != NSNotFound) {
        return kLRCollision_BottomBarrier_SectionBlock;
    }
    return kLRCollision_Undefined;
}

@end
