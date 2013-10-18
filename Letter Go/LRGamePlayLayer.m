//
//  LRGamePlayLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGamePlayLayer.h"
#import "LRLetterBlockGenerator.h"
#import "LRConstants.h"
#import "LRCollisionManager.h"
#import "LRGameStateManager.h"

@implementation LRGamePlayLayer

- (id) init
{
    if (self = [super init])
    {
        //Code here :)
        self.name = NAME_LAYER_GAME_PLAY;
        [self createLayerContent];
        [self setUpPhysics];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropLetter:) name:NOTIFICATION_DROP_LETTER object:nil];
    }
    return self;
}

- (void) createLayerContent
{
    //Create the three sections
    CGFloat healthHeight = 7;
    CGFloat letterHeight = 70;
    self.healthSection = [[LRHealthSection alloc] initWithSize:CGSizeMake(self.size.width, healthHeight)];
    self.healthSection.position = CGPointMake(0, self.size.height/2 - self.healthSection.size.height/2);
    self.healthSection.zPosition += 15;
    
    
    SKSpriteNode *tempHealth = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:self.healthSection.size];
    tempHealth.alpha = .5;
    tempHealth.position = self.healthSection.position;
    [self addChild:tempHealth];

    [self addChild:self.healthSection];

    self.letterSection = [[LRLetterSection alloc] initWithSize:CGSizeMake(self.size.width, letterHeight)];
    self.letterSection.position = CGPointMake(self.position.x - self.size.width/2, 0 - self.size.height/2 + self.letterSection.size.height/2);
    [self addChild:self.letterSection];
    
    //TEMPORARY: blocks will be continuously created by the game play layer
    [self dropInitialLetters];
}

- (void) setUpPhysics
{
    //Add a line so that the block doesn't just fall forever
    float edgeHeight = self.letterSection.position.y + self.letterSection.size.height/2;
    CGPoint leftScreen = CGPointMake(0 - self.size.width /2, edgeHeight);
    CGPoint rightScreen = CGPointMake (self.size.width/2, edgeHeight);
    SKPhysicsBody *blockEdge = [SKPhysicsBody bodyWithEdgeFromPoint:leftScreen toPoint:rightScreen];
    SKSpriteNode *blockEdgeSprite = [[SKSpriteNode alloc] init];
    blockEdgeSprite.name = NAME_SPRITE_BOTTOM_EDGE;
    blockEdgeSprite.physicsBody = blockEdge;
    [[LRCollisionManager shared] setBitMasksForSprite:blockEdgeSprite];
    [self addChild:blockEdgeSprite];
}

- (void) dropInitialLetters
{
    for (int i = 0; i < 3; i++) {
        SKAction *delay = [SKAction waitForDuration:(i * .3)];
        SKAction *drop = [SKAction runBlock:^{
            [self addChild:[LRLetterBlockGenerator createRandomEnvelopeAtSlot:i]];
        }];
        [self runAction:[SKAction sequence:[NSArray arrayWithObjects:delay, drop, nil]]];
    }

}

- (void) dropLetter:(NSNotification*) notification
{
    //This will be moved to the difficulty manager, which will be doing the dropping
    if ([[LRGameStateManager shared] isGameOver])
        return;
    int slot = [[[notification userInfo] objectForKey:@"slot"] intValue];
    [self addChild:[LRLetterBlockGenerator createRandomEnvelopeAtSlot:slot]];
}
@end
