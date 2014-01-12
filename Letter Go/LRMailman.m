//
//  LRMailman.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/3/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRMailman.h"
#import "LRPositionConstants.h"
#import "LRCollisionManager.h"
#import "LRFallingEnvelope.h"
#import "LRDifficultyManager.h"

#define IMAGE_NAME_MAILMAN          @"Manford.png"
#define IMAGE_NAME_COVER            @"Manford_Cover.png"

static const CGFloat kLetterEntryPointX = 195.0;
static const CGFloat kLetterEntryPointY = -35.0;

@interface LRMailman()
@property (readwrite) CGPoint letterEntryPoint;
@property (nonatomic, strong) SKSpriteNode *mailbagCover;
@end

@implementation LRMailman

#pragma mark - Set Up/Initialization

- (id) init
{
    if (self = [super initWithImageNamed:IMAGE_NAME_MAILMAN]) {
        self.name = NAME_SPRITE_MAILMAN;
        [self setScale:.7];
        [self setUpPhysics];
        [self addChild:self.mailbagCover];
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
}

- (SKSpriteNode*) mailbagCover
{
    if (!_mailbagCover) {
        _mailbagCover = [SKSpriteNode spriteNodeWithImageNamed:IMAGE_NAME_COVER];
        _mailbagCover.position =  CGPointMake(0, -7);
        _mailbagCover.zPosition = zPos_Mailbag;
    }
    return _mailbagCover;
}

#pragma mark - Screen Side Functions

- (void)setScreenSide:(MailmanScreenSide)screenSide
{
    CGFloat xPos = [self xPositionForScreenSide:screenSide];
    CGFloat yPos = 0 - SCREEN_HEIGHT/2 + kSectionHeightLetterSection + self.size.height/2;
    self.position = CGPointMake(xPos, yPos);
    
    if (screenSide == MailmanScreenLeft) {
        self.letterEntryPoint = CGPointMake(-kLetterEntryPointX, kLetterEntryPointY);
    }
    else {
        self.letterEntryPoint = CGPointMake(kLetterEntryPointX, kLetterEntryPointY);
    }
    _screenSide = screenSide;

}

- (CGFloat) xPositionForScreenSide:(MailmanScreenSide)screenSide
{
    CGFloat xOffset = 5;
    float mailmanX = (screenSide == MailmanScreenLeft) ?
            0 - SCREEN_WIDTH/2 + self.size.width/2 + xOffset :
            SCREEN_WIDTH/2 - self.size.width/2 - xOffset;
    return mailmanX;
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
@end
