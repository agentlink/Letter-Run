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
    if ([nameSet containsObject:NAME_SPRITE_FALLING_ENVELOPE] &&
        [nameSet containsObject:NAME_SPRITE_BOTTOM_EDGE])
    {
        SKNode *letterBlock = ([firstBody.node.name isEqualToString:NAME_SPRITE_FALLING_ENVELOPE]) ? firstBody.node : secondBody.node;
        [self blockHitGround:(SKSpriteNode*)letterBlock];
    }
    
}

- (void) blockHitGround:(SKSpriteNode*)block
{
    NSDictionary *blockDict = [NSDictionary dictionaryWithObject:block forKey:KEY_GET_LETTER_BLOCK];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENVELOPE_HIT_GROUND object:self userInfo:blockDict];
}
@end
