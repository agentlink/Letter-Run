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

//Add contact/collision detection to all future sprites with recipient name
- (void) addCollisionDetectionOfSpritesNamed:(NSString *)colliderName toSpritesNamed:(NSString*) recipientName;
- (void) addContactDetectionOfSpritesNamed:(NSString *)colliderName toSpritesNamed:(NSString*) recipientName;

//Add contact/collision detection to a specific sprite
- (void) addContactDetectionOfSpriteNamed:(NSString*)colliderName toSprite:(SKSpriteNode*)recipient;
- (void) addCollisionDetectionOfSpriteNamed:(NSString*)colliderName toSprite:(SKSpriteNode*)recipient;

//Remove contact/collision detection from a specific sprite
- (void) removeCollisionDetectionOfSpriteNamed:(NSString *)colliderName toSprite:(SKSpriteNode *)recipient;
- (void) removeContactDetectionOfSpriteNamed:(NSString *)colliderName toSprite:(SKSpriteNode *)recipient;

@end
