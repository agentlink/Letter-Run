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
        if ([firstBody.node.name isEqualToString:NAME_SPRITE_BOTTOM_EDGE])
            [self attachGround:(SKSpriteNode*)firstBody.node andBlock:(SKSpriteNode*)secondBody.node];
        else
            [self attachGround:(SKSpriteNode*)secondBody.node andBlock:(SKSpriteNode*)firstBody.node];
    }
    
}

- (void) attachGround:(SKSpriteNode*)ground andBlock:(SKSpriteNode*)letterBlock
{
    //Attach the objects with a physics joint
    CGPoint intersect = CGPointMake(letterBlock.position.x, letterBlock.frame.origin.y);
    SKPhysicsJointFixed *joint = [SKPhysicsJointFixed jointWithBodyA:ground.physicsBody bodyB:letterBlock.physicsBody
                                                              anchor:intersect];
    [letterBlock.scene.physicsWorld addJoint:joint];
}
@end
