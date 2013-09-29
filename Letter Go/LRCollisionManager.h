//
//  LRCollisionManager.h
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/9/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRCollisionManager : SKNode <SKPhysicsContactDelegate>

+ (LRCollisionManager *) shared;
- (void) setBitMasksForSprite:(SKSpriteNode*)sprite;
- (void) addCollisionDetectionOfSpriteNamed:(NSString *)colliderName toSprite:(SKSpriteNode*) recipient;
- (void) addContactDetectionOfSpriteNamed:(NSString *)colliderName toSprite:(SKSpriteNode*) recipient;

- (void) removeCollisionDetectionOfSpriteNamed:(NSString *)colliderName toSprite:(SKSpriteNode *)recipient;

@end
