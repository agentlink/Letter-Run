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
#import "LRDifficultyManager.h"

#define NUM_SLOTS               3

@interface LRGamePlayLayer ()
@property NSMutableArray *letterSlots;
@end

@implementation LRGamePlayLayer

#pragma mark - Set Up/Initialization

- (id) init
{
    if (self = [super init])
    {
        //Code here :)
        self.name = NAME_LAYER_GAME_PLAY;
        [self createLayerContent];
        [self setUpPhysics];
        [self setUpSlotArray];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSlots:) name:NOTIFICATION_LETTER_CLEARED object:nil];
        
        [self dropInitialLetters];
    }
    return self;
}

- (void) createLayerContent
{
    //Create the three sections
    self.healthSection = [[LRHealthSection alloc] initWithSize:CGSizeMake(self.size.width, SIZE_HEIGHT_HEALTH_SECTION)];
    self.healthSection.position = CGPointMake(0, self.size.height/2 - self.healthSection.size.height/2);
    self.healthSection.zPosition += 15;
    
    
    SKSpriteNode *tempHealth = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:self.healthSection.size];
    tempHealth.alpha = .5;
    tempHealth.position = self.healthSection.position;
    [self addChild:tempHealth];

    [self addChild:self.healthSection];

    self.letterSection = [[LRLetterSection alloc] initWithSize:CGSizeMake(self.size.width, SIZE_HEIGHT_LETTER_SECTION)];
    self.letterSection.position = CGPointMake(self.position.x - self.size.width/2, 0 - self.size.height/2 + self.letterSection.size.height/2);
    [self addChild:self.letterSection];
}

- (void) setUpPhysics
{
    //Add a line so that the block doesn't just fall forever
    float edgeBuffer = 0;
    
    float edgeHeight = self.letterSection.position.y + self.letterSection.size.height/2 + edgeBuffer;
    CGPoint leftScreen = CGPointMake(0 - self.size.width /2, edgeHeight);
    CGPoint rightScreen = CGPointMake (self.size.width/2, edgeHeight);
    
    SKPhysicsBody *blockEdge = [SKPhysicsBody bodyWithEdgeFromPoint:leftScreen toPoint:rightScreen];
    SKSpriteNode *blockEdgeSprite = [[SKSpriteNode alloc] init];
    blockEdgeSprite.name = NAME_SPRITE_BOTTOM_EDGE;
    blockEdgeSprite.physicsBody = blockEdge;
    blockEdgeSprite.position = CGPointMake(0, edgeHeight);
    
    [[LRCollisionManager shared] setBitMasksForSprite:blockEdgeSprite];
    [self addChild:blockEdgeSprite];
}

- (void) setUpSlotArray
{
    self.letterSlots = [[NSMutableArray alloc] initWithCapacity:NUM_SLOTS];
    for (int i = 0; i < NUM_SLOTS; i ++) {
        [ self.letterSlots addObject:[NSMutableArray array]];
    }
}


#pragma mark - Letter Drop Functions

- (void) dropInitialLetters
{
    for (int i = 0; i < NUM_SLOTS - 1; i++) {
        SKAction *delay = [SKAction waitForDuration:(i * .6)];
        SKAction *drop = [SKAction runBlock:^{
            [self dropLetterAtSlot:i];
        }];
        [self runAction:[SKAction sequence:@[delay, drop]]];
    }
    [self letterDropLoop];
}

- (void) dropLetter {
    //Find an empty slot and then dorp the letter at that slot
    NSMutableArray *emptySlots = [NSMutableArray array];
    for (int i = 0; i <  self.letterSlots.count; i++)
    {
        NSArray *slotArray = [ self.letterSlots objectAtIndex:i];
        if (![slotArray count]) {
            [emptySlots addObject:[NSNumber numberWithInt:i]];
        }
    }
    //If there isn't an empty slot, drop it at a full one
    int letterDropSlot = ([emptySlots count]) ? [[emptySlots objectAtIndex:arc4random()%emptySlots.count] intValue] : arc4random()%NUM_SLOTS;
    [self dropLetterAtSlot:letterDropSlot];
}

- (void) dropLetterAtSlot:(int)slotLocation
{
    NSAssert(slotLocation < NUM_SLOTS, @"Error: slot %i is outside of bounds.", slotLocation);
    LRFallingEnvelope *envelope = [LRLetterBlockGenerator createRandomEnvelopeAtSlot:slotLocation];
    [self addChild:envelope];
    [envelope dropEnvelopeWithSwing];
    
    [[ self.letterSlots objectAtIndex:slotLocation] addObject:[NSNumber numberWithBool:TRUE]];
}

- (void) letterDropLoop
{
    if ([[LRGameStateManager shared] isGameOver])
        return;
    float delayTime = [[LRDifficultyManager shared] letterDropPeriod];
    SKAction *delay = [SKAction waitForDuration:delayTime];
    SKAction *dropLetter = [SKAction runBlock:^{
        [self dropLetter];
    }];
    SKAction *waitAndDrop = [SKAction sequence:@[delay, dropLetter]];
    [self runAction:waitAndDrop completion:^{
        [self letterDropLoop];
    }];
}

- (void) updateSlots:(NSNotification*) notification
{
    //This will be moved to the difficulty manager, which will be doing the dropping
    if ([[LRGameStateManager shared] isGameOver])
        return;
    int slot = [[[notification userInfo] objectForKey:@"slot"] intValue];
    NSAssert([[ self.letterSlots objectAtIndex:slot] count], @"Error: cannot remove block from empty slot");
    [[ self.letterSlots objectAtIndex:slot] removeLastObject];
    
}
@end
