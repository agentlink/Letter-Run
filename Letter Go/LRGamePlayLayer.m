//
//  LRGamePlayLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGamePlayLayer.h"
#import "LRLetterBlockGenerator.h"

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
        [self setUpSlotArray];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSlots:) name:NOTIFICATION_LETTER_CLEARED object:nil];
        [self setUpPhysics];
        [self dropInitialLetters];
    }
    return self;
}

- (void) createLayerContent
{
    //Health Section
    self.healthSection = [[LRHealthSection alloc] initWithSize:CGSizeMake(self.size.width, SIZE_HEIGHT_HEALTH_SECTION)];
    self.healthSection.position = CGPointMake(0, self.size.height/2 - self.healthSection.size.height/2);
    self.healthSection.zPosition += 15;
    
    SKSpriteNode *tempHealth = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:self.healthSection.size];
    tempHealth.alpha = .5;
    tempHealth.position = self.healthSection.position;
    [self addChild:tempHealth];

    [self addChild:self.healthSection];

    //Letter Section
    self.letterSection = [[LRLetterSection alloc] initWithSize:CGSizeMake(self.size.width, SIZE_HEIGHT_LETTER_SECTION)];
    self.letterSection.position = CGPointMake(self.position.x - self.size.width/2, 0 - self.size.height/2 + self.letterSection.size.height/2);
    [self addChild:self.letterSection];
    
    //Mailman
    self.mailman = [[LRMailman alloc] init];
    float xOffset = 5;
    float mailmanX = self.position.x - self.size.width + self.mailman.size.width/2 + xOffset;
    float mailmanY = self.letterSection.position.y + (self.letterSection.size.height + self.mailman.size.height)/2;
    self.mailman.position = CGPointMake(mailmanX, mailmanY);
    [self addChild:self.mailman];
    
    //Pause Button
    self.pauseButton = [[LRButton alloc] initWithImageNamedNormal:@"Pause_Temp.png" selected:@"Pause_Temp.png"];
    [self.pauseButton setTouchUpInsideTarget:self action:@selector(pauseButtonPressed)];
    self.pauseButton.position = CGPointMake(0 - SCREEN_WIDTH/2 + self.pauseButton.size.width/2, SCREEN_HEIGHT/2 - self.healthSection.size.height - self.pauseButton.size.height/2);
;
    [self addChild:self.pauseButton];
}

- (void) setUpSlotArray
{
    self.letterSlots = [[NSMutableArray alloc] initWithCapacity:NUM_SLOTS];
    for (int i = 0; i < NUM_SLOTS; i ++) {
        [ self.letterSlots addObject:[NSMutableArray array]];
    }
}

- (void) setUpPhysics
{
    //Add a line so that the block doesn't just fall forever
    float edgeBuffer = 0;
    
    float edgeHeight = self.letterSection.position.y + self.letterSection.size.height/2 + edgeBuffer;
    CGPoint leftScreen = CGPointMake(0 - self.size.width /2, 0);
    CGPoint rightScreen = CGPointMake (self.size.width/2, 0);
    
    SKPhysicsBody *blockEdge = [SKPhysicsBody bodyWithEdgeFromPoint:leftScreen toPoint:rightScreen];
    SKSpriteNode *blockEdgeSprite = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(SCREEN_WIDTH, 1)];
    blockEdgeSprite.name = NAME_SPRITE_BOTTOM_EDGE;
    blockEdgeSprite.physicsBody = blockEdge;
    blockEdgeSprite.position = CGPointMake(0, edgeHeight);
    
    [[LRCollisionManager shared] setBitMasksForSprite:blockEdgeSprite];
    [self addChild:blockEdgeSprite];
}

#pragma mark - Game Loop Functions

- (void) update:(NSTimeInterval)currentTime
{
    //Check on the falling envelopes to see if they are outside the screen
    CGRect sceneFrame = self.frame;
    sceneFrame.origin = CGPointMake(0 - SCREEN_WIDTH/2, 0 - SCREEN_HEIGHT/2 - self.letterSection.size.height);
    sceneFrame.size = CGSizeMake(sceneFrame.size.width, sceneFrame.size.height + self.letterSection.size.height);
    
    CGRect extendedLetterFrame = self.letterSection.frame;
    extendedLetterFrame.origin = CGPointMake(extendedLetterFrame.origin.x, extendedLetterFrame.origin.y - extendedLetterFrame.size.height);
    extendedLetterFrame.size = CGSizeMake(extendedLetterFrame.size.width, extendedLetterFrame.size.height * 2);
    
    NSMutableArray *childrenToRemove = [NSMutableArray array];
    
    [self enumerateChildNodesWithName:NAME_SPRITE_FALLING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        LRFallingEnvelope *envelope = (LRFallingEnvelope*)node;
        if (!CGRectIntersectsRect(envelope.frame, sceneFrame) &&
            (envelope.blockState == BlockState_Landed || envelope.blockState == BlockState_BlockFlung)) {
            NSMutableDictionary *dropLetterInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:envelope.slot] forKey:@"slot"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LETTER_CLEARED object:self userInfo:dropLetterInfo];
            [childrenToRemove addObject:envelope];
        }
    }];
    [self removeChildrenInArray:childrenToRemove];
    [super update:currentTime];
}

- (void) pauseButtonPressed
{
    if ([[LRGameStateManager shared] isGamePaused]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_CONTINUE_GAME object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_PAUSE_GAME object:nil];
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
    if ([[LRGameStateManager shared] isGamePaused])
        return;
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
    float delayTime = [[LRDifficultyManager shared] letterDropPeriod];
    SKAction *delay = [SKAction waitForDuration:delayTime];
    SKAction *dropLetter = [SKAction runBlock:^{
        [self dropLetter];
    }];
    SKAction *waitAndDrop = [SKAction sequence:@[delay, dropLetter]];
    
    SKAction *dropLoop = [SKAction runBlock:^{
        [self runAction:waitAndDrop completion:^{
            [self letterDropLoop];
        }];
    }];
    [self runAction:dropLoop withKey:ACTION_ENVELOPE_LOOP];
}

- (void) updateSlots:(NSNotification*) notification
{
    //This will be moved to the difficulty manager, which will be doing the dropping
    if ([[LRGameStateManager shared] isGameOver] || [[LRGameStateManager shared] isGamePaused])
        return;
    int slot = [[[notification userInfo] objectForKey:@"slot"] intValue];
    NSAssert([[ self.letterSlots objectAtIndex:slot] count], @"Error: cannot remove block from empty slot");
    [[ self.letterSlots objectAtIndex:slot] removeLastObject];
    
}

#pragma mark - Board Properties
- (CGPoint) flungEnvelopeDestination
{
    return [self.mailman mailBagLocation];
}

@end
