//
//  LRCollisionManager.h
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/9/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRCollisionManager : SKNode <SKPhysicsContactDelegate>

+ (LRCollisionManager *)shared;
- (void)setBitMasksForSprite:(SKSpriteNode *)sprite;

//Add contact/collision detection to all future sprites with recipient name
- (void)addCollisionDetectionOfSpritesNamed:(NSString *)colliderName toSpritesNamed:(NSString *)recipientName;
- (void)addContactDetectionOfSpritesNamed:(NSString *)colliderName toSpritesNamed:(NSString *)recipientName;

//Add contact/collision detection of all sprites with a name to a specific sprite
- (void)addContactDetectionOfSpritesNamed:(NSString *)colliderName toSprite:(SKSpriteNode *)recipient;
- (void)addCollisionDetectionOfSpritesNamed:(NSString *)colliderName toSprite:(SKSpriteNode *)recipient;

//Remove contact/collision detection from a specific sprite
- (void)removeCollisionDetectionOfSpritesNamed:(NSString *)colliderName toSprite:(SKSpriteNode *)recipient;
- (void)removeContactDetectionOfSpritesNamed:(NSString *)colliderName toSprite:(SKSpriteNode *)recipient;

@end
