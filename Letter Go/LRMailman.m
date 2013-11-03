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

#define IMAGE_NAME_MAILMAN          @"Mailman_Temp.png"

@implementation LRMailman

#pragma mark - Set Up/Initialization

- (id) init
{
    if (self = [super initWithImageNamed:IMAGE_NAME_MAILMAN]) {
        self.name = NAME_SPRITE_MAILMAN;
        [self setScale:.7];
        
        [self setUpPhysics];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hitByEnvelope:) name:NOTIFICATION_ENVELOPE_HIT_MAILMAN object:nil];
    }
    return self;
}

- (void) setUpPhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.dynamic = YES;
    self.physicsBody.affectedByGravity = NO;
    
    [[LRCollisionManager shared] setBitMasksForSprite:self];
    [[LRCollisionManager shared] addContactDetectionOfSpritesNamed:NAME_SPRITE_FALLING_ENVELOPE toSprite:self];
}

# pragma mark - Contact Functions
- (void) hitByEnvelope:(NSNotification*)notification
{
    LRFallingEnvelope *envelope = [[notification userInfo] objectForKey:KEY_GET_LETTER_BLOCK];
    NSLog(@"Mailman hit by letter %@", envelope.letter);
}
@end
