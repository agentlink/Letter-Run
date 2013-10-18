//
//  LRCollisionManager.m
//  GhostGame
//
//  Created by Gabriel Nicholas on 9/9/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRCollisionManager.h"
#import "LRConstants.h"

#define BITMASK_KEY_CATEGORY            @"Bitmask category"
#define BITMASK_KEY_COLLISION           @"Bitmask collision"
#define BITMASK_KEY_CONTACT             @"Bitmask contact"

@interface LRCollisionManager ()
@property NSMutableDictionary* bitMaskDictionary;
@end

@implementation LRCollisionManager

#pragma mark - Set Up

static LRCollisionManager *_shared = nil;

+ (LRCollisionManager*) shared
{
    //This @synchronized line is for multithreading
    @synchronized (self)
    {
		if (!_shared)
        {
			_shared = [[LRCollisionManager alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init])
    {
        [self setUpBitMaskDictionary];
    }
    return self;
}

- (void) setUpBitMaskDictionary
{
    /*
     This dictionary contains one sub-dictionary for every character. Each character is
     assigned a unique one of thirty two categories. These categories are character's IDs that
     determine when characters collide with each other (i.e. interact in a physical way) and which
     characters call funcitons when they contact each other. These contact and collision
     dictionaries are also stored in a character's sub-dictionary.
     */
    
    NSArray *spriteNameArray = [NSArray arrayWithObjects:NAME_SPRITE_FALLING_ENVELOPE, NAME_SPRITE_BOTTOM_EDGE, nil];
    self.bitMaskDictionary = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [spriteNameArray count]; i++) {
        NSMutableDictionary *spriteDict = [[NSMutableDictionary alloc] init];
        int bitMaskCategory = 0x1 << i;
        [spriteDict setObject:[NSNumber numberWithInt:bitMaskCategory] forKey:BITMASK_KEY_CATEGORY];
        [spriteDict setObject:[NSNumber numberWithInt:0] forKey:BITMASK_KEY_CONTACT];
        [spriteDict setObject:[NSNumber numberWithInt:0] forKey:BITMASK_KEY_COLLISION];
        [self.bitMaskDictionary setObject:spriteDict forKey:(NSString*)[spriteNameArray objectAtIndex:i]];
    }
}

#pragma mark - 

#pragma mark - Physics Bitmask Public Functions

- (void) setBitMasksForSprite:(SKSpriteNode*)sprite
{
    //Look up the dictionary values for a given characters category, collision data, and contact data.
    NSString *name = sprite.name;
    NSAssert(name, @"Error: attempting to set a bit mask for a character without a name");

    sprite.physicsBody.categoryBitMask = [self getCategoryMaskForSpriteWithName:name];
    sprite.physicsBody.collisionBitMask = [self getCollisionMaskForSpriteWithName:name];
    sprite.physicsBody.contactTestBitMask = [self getContactMaskForSpirteWithName:name];
}

#pragma mark - Adding Class Collision/Contact Detection

- (void) addCollisionDetectionOfSpritesNamed:(NSString *)colliderName toSpritesNamed:(NSString*) recipientName
{
    //Call this function when two objects should physically interact upon collision
    //The recipient is the one that detects the collision
    uint32_t recipientCollisionMask = [self getCollisionMaskForSpriteWithName:recipientName];
    uint32_t colliderCategoryMask = [self getCategoryMaskForSpriteWithName:colliderName];
    
    NSMutableDictionary* spriteDictionary = (NSMutableDictionary*)[self.bitMaskDictionary objectForKey:recipientName];
    [spriteDictionary setObject:[NSNumber numberWithInt:(recipientCollisionMask | colliderCategoryMask)] forKey:BITMASK_KEY_COLLISION];
}

- (void) addContactDetectionOfSpritesNamed:(NSString *)colliderName toSpritesNamed:(NSString *)recipientName
{
    uint32_t recipientContactMask = [self getContactMaskForSpirteWithName:recipientName];
    uint32_t contacterBitMask = [self getCategoryMaskForSpriteWithName:colliderName];
    
    NSMutableDictionary* spriteDictionary = (NSMutableDictionary*)[self.bitMaskDictionary objectForKey:recipientName];
    [spriteDictionary setObject:[NSNumber numberWithInt:(recipientContactMask | contacterBitMask)] forKey:BITMASK_KEY_CONTACT];
}

#pragma mark - Adding Instance Collision/Contact Detection

- (void) addContactDetectionOfSpriteNamed:(NSString*)colliderName toSprite:(SKSpriteNode*)recipient
{
    NSString *recipientName = recipient.name;
    uint32_t recipientContactMask = [self getContactMaskForSpirteWithName:recipientName];
    uint32_t contacterBitMask = [self getCategoryMaskForSpriteWithName:colliderName];
    recipient.physicsBody.contactTestBitMask = recipientContactMask | contacterBitMask;
}

- (void) addCollisionDetectionOfSpriteNamed:(NSString*)colliderName toSprite:(SKSpriteNode*)recipient
{
    NSString *recipientName = recipient.name;
    uint32_t recipientCollisionMask = [self getCollisionMaskForSpriteWithName:recipientName];
    uint32_t colliderBitMask = [self getCategoryMaskForSpriteWithName:colliderName];
    recipient.physicsBody.collisionBitMask = recipientCollisionMask | colliderBitMask;
}

#pragma mark - Removing Instance Collision/Contact Detection
- (void) removeCollisionDetectionOfSpriteNamed:(NSString *)colliderName toSprite:(SKSpriteNode *)recipient
{
    NSString *recipientName = recipient.name;
    uint32_t recipientContactMask = [self getCollisionMaskForSpriteWithName:recipientName];
    uint32_t contacterBitMask = [self getCategoryMaskForSpriteWithName:colliderName];
    contacterBitMask = ~contacterBitMask;
    recipient.physicsBody.collisionBitMask = recipientContactMask | contacterBitMask;
}

- (void) removeContactDetectionOfSpriteNamed:(NSString *)colliderName toSprite:(SKSpriteNode *)recipient
{
    NSString *recipientName = recipient.name;
    uint32_t recipientContactMask = [self getContactMaskForSpirteWithName:recipientName];
    uint32_t contacterBitMask = [self getCategoryMaskForSpriteWithName:colliderName];
    contacterBitMask = ~contacterBitMask;
    recipient.physicsBody.contactTestBitMask = recipientContactMask | contacterBitMask;
}

#pragma mark - Mask Dictionary Look Up Functions

- (uint32_t) getCategoryMaskForSpriteWithName:(NSString *)spriteName
{
    NSDictionary *spriteDictionary = [self.bitMaskDictionary objectForKey:spriteName];
    NSNumber *bitMask = [spriteDictionary objectForKey:BITMASK_KEY_CATEGORY];
    return [bitMask intValue];
}

- (uint32_t) getContactMaskForSpirteWithName:(NSString *)spriteName
{
    NSDictionary *spriteDictionary = [self.bitMaskDictionary objectForKey:spriteName];
    NSNumber *bitMask = [spriteDictionary objectForKey:BITMASK_KEY_CONTACT];
    return [bitMask intValue];
}

- (uint32_t) getCollisionMaskForSpriteWithName:(NSString *)spriteName
{
    NSNumber *bitMask = [(NSDictionary*)[self.bitMaskDictionary objectForKey:spriteName] objectForKey:BITMASK_KEY_COLLISION];
    return bitMask.intValue;
}

#pragma mark - Contact Functions

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
    NSLog(@"%@ hit %@", firstBody.node.name, secondBody.node.name);
}

#pragma mark - Tear Down

- (void) dealloc
{
    self.bitMaskDictionary = nil;
}

@end
