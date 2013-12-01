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

#define NUM_SLOTS               4

@interface LRGamePlayLayer ()
@property NSMutableArray *letterSlots;

@property BOOL newGame;
@property NSTimeInterval nextDropTime;
@property NSTimeInterval pauseTime;
@property int lastSlot;

@end

@implementation LRGamePlayLayer
@synthesize newGame, pauseTime, nextDropTime;

#pragma mark - Set Up/Initialization

- (id) init
{
    if (self = [super init])
    {
        //Code here :)
        newGame = TRUE;
        self.pauseTime = GAME_LOOP_RESET;
        self.lastSlot = -1;
        self.name = NAME_LAYER_GAME_PLAY;
        [self createLayerContent];
        [self setUpSlotArray];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSlots:) name:NOTIFICATION_LETTER_CLEARED object:nil];
        [self setUpPhysics];
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
    self.pauseButton = [[LRButton alloc] initWithImageNamedNormal:@"Pause_Selected.png" selected:@"Pause_Unselected.png"];
    [self.pauseButton setScale:.7];
    [self.pauseButton setTouchUpInsideTarget:self action:@selector(pauseButtonPressed)];
    self.pauseButton.position = CGPointMake(0 - SCREEN_WIDTH/2 + self.pauseButton.size.width/2, SCREEN_HEIGHT/2 - self.healthSection.size.height - self.pauseButton.size.height/2);

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

- (void) pauseButtonPressed
{
    NSString *notifName = ([[LRGameStateManager shared] isGamePaused]) ? GAME_STATE_CONTINUE_GAME : GAME_STATE_PAUSE_GAME;
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:nil];
}

#pragma mark - Letter Drop Functions
- (void) update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    //If the game is over
    if ([[LRGameStateManager shared] isGameOver]) {
        newGame = TRUE;
        return;
    }
    //If the game is paused
    else if ([[LRGameStateManager shared] isGamePaused]) {
        if (pauseTime != GAME_LOOP_RESET)
            pauseTime = nextDropTime - currentTime;
        return;
    }
    //If a new game has just begun
    else if (newGame) {
        nextDropTime = currentTime;
        newGame = FALSE;
    }
    //If the game has just been unpaused
    else if (pauseTime != GAME_LOOP_RESET) {
        nextDropTime = currentTime + pauseTime;
        pauseTime = GAME_LOOP_RESET;
    }
    
    if (currentTime >= nextDropTime) {
        int i = 0;
        for (i = 0; i < [[LRDifficultyManager shared] numLettersPerDrop]; i++) {
            [self dropLetter];
        }
        nextDropTime = currentTime + [[LRDifficultyManager shared] letterDropPeriod];
    }
}

- (void) dropInitialLetters
{
    for (int i = 0; i < NUM_SLOTS; i++) {
        SKAction *delay = [SKAction waitForDuration:(i * .6)];
        SKAction *drop = [SKAction runBlock:^{
            [self dropLetterAtSlot:i];
        }];
        [self runAction:[SKAction sequence:@[delay, drop]]];
    }
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
    int letterDropSlot = self.lastSlot;
    if ([emptySlots count])
        letterDropSlot = [[emptySlots objectAtIndex:arc4random()%emptySlots.count] intValue];
    else {
        while (letterDropSlot == self.lastSlot) {
            letterDropSlot = arc4random()%NUM_SLOTS;
        }
    }
    [self dropLetterAtSlot:letterDropSlot];
    self.lastSlot = letterDropSlot;
}

- (void) dropLetterAtSlot:(int)slotLocation
{
    NSAssert(slotLocation < NUM_SLOTS, @"Error: slot %i is outside of bounds.", slotLocation);
    LRFallingEnvelope *envelope = [LRLetterBlockGenerator createRandomEnvelopeAtSlot:slotLocation];
    [self addChild:envelope];
    [envelope dropEnvelopeWithSwing];
    
    [[self.letterSlots objectAtIndex:slotLocation] addObject:[NSNumber numberWithBool:TRUE]];
}

- (void) updateSlots:(NSNotification*) notification
{
    if ([[LRGameStateManager shared] isGameOver] || [[LRGameStateManager shared] isGamePaused])
        return;
    int slot = [[[notification userInfo] objectForKey:@"slot"] intValue];
    NSAssert([[ self.letterSlots objectAtIndex:slot] count], @"Error: cannot remove block from empty slot");
    [[self.letterSlots objectAtIndex:slot] removeLastObject];
    
}

#pragma mark - Board Properties
- (CGPoint) flungEnvelopeDestination
{
    return [self.mailman mailBagLocation];
}

@end
