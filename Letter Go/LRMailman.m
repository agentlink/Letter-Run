//
//  LRMailman.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/3/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRMailman.h"
#import "LRCollisionManager.h"
#import "LRFallingEnvelope.h"
#import "LRDifficultyManager.h"

#define IMAGE_NAME_MAILMAN          @"Manford.png"

@implementation LRMailman

#pragma mark - Set Up/Initialization

- (id) init
{
    if (self = [super initWithImageNamed:IMAGE_NAME_MAILMAN]) {
        self.name = NAME_SPRITE_MAILMAN;
        [self setScale:.7];
        //self.userInteractionEnabled = YES;
        [self setUpPhysics];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hitByEnvelope:) name:NOTIFICATION_ENVELOPE_HIT_MAILMAN object:nil];
    }
    return self;
}

- (void) setUpPhysics
{
    CGSize damageSize = CGSizeMake(self.size.width * .75 , self.size.height * .75);
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:damageSize];
    self.physicsBody.dynamic = YES;
    self.physicsBody.affectedByGravity = NO;
    
    [[LRCollisionManager shared] setBitMasksForSprite:self];
    [[LRCollisionManager shared] addContactDetectionOfSpritesNamed:NAME_SPRITE_FALLING_ENVELOPE toSprite:self];
    
    [self mailBagLocation];
}

# pragma mark - Contact Functions
- (void) hitByEnvelope:(NSNotification*)notification
{
    if (![[LRDifficultyManager shared] mailmanReceivesDamage])
        return;
    LRFallingEnvelope *envelope = [[notification userInfo] objectForKey:KEY_GET_LETTER_BLOCK];
    
    if (envelope.blockState == BlockState_BlockFlung)
        return;
    //Remove the envlope
    [envelope envelopeHitMailman];

    //Pulse the mailman red
    CGFloat duration = .6;
    SKColor *pulseColor = [SKColor redColor];
    SKAction *pulseRed = [SKAction colorizeWithColor:pulseColor colorBlendFactor:.5 duration:duration/2];
    SKAction *pulseBack = [SKAction colorizeWithColor:pulseColor colorBlendFactor:0 duration:duration/2];
    [self runAction:[SKAction sequence:@[pulseRed, pulseBack]]];
    
}

- (CGPoint)mailBagLocation
{
    //Returns the location of the mailbag in the parent node
    return CGPointMake(-170.0, -28.0);
}

/*
 - (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
 {
 for (UITouch *touch in touches)
 {
 CGPoint location = [touch locationInNode:[self parent]];
 NSLog(@"%f, %f", location.x, location.y);
 }
 
 }
 */
@end
