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
#import "LRFallingEnvelopeSlotManager.h"
#import "LRPositionConstants.h"

@interface LRGamePlayLayer ()
@property LRFallingEnvelopeSlotManager *letterSlots;

@property BOOL newGame;
@property NSTimeInterval nextDropTime;
@property NSTimeInterval pauseTime;

@end

@implementation LRGamePlayLayer
@synthesize newGame, pauseTime, nextDropTime;

#pragma mark - Set Up/Initialization

- (id) init
{
    if (self = [super init])
    {
        self.pauseTime = GAME_LOOP_RESET;
        self.name = NAME_LAYER_GAME_PLAY;
        newGame = TRUE;
        self.letterSlots = [[LRFallingEnvelopeSlotManager alloc] init];
        [self createLayerContent];
        [self setUpPhysics];
    }
    return self;
}


- (void) createLayerContent
{
    [self addChild:self.healthSection];
    [self addChild:self.letterSection];
    [self addChild:self.mailman];
    [self addChild:self.pauseButton];
}

#pragma mark - Layer Content Set Up

- (LRHealthSection*) healthSection
{
    if (!_healthSection) {
        _healthSection = [[LRHealthSection alloc] initWithSize:CGSizeMake(self.size.width, SIZE_HEIGHT_HEALTH_SECTION)];
        _healthSection.position = CGPointMake(0, self.size.height/2 - SIZE_HEIGHT_HEALTH_SECTION/2);
        _healthSection.zPosition = zPos_HealthSection;
    }
    return _healthSection;
}

- (LRLetterSection*) letterSection
{
    if (!_letterSection) {
        _letterSection = [[LRLetterSection alloc] initWithSize:CGSizeMake(self.size.width, SIZE_HEIGHT_LETTER_SECTION)];
        _letterSection.position = CGPointMake(self.position.x - self.size.width/2, 0 - self.size.height/2 + self.letterSection.size.height/2);
        _letterSection.zPosition = zPos_LetterSection;
    }
    return _letterSection;
}

- (LRMailman*) mailman
{
    if (!_mailman) {
        _mailman = [[LRMailman alloc] init];
        _mailman.screenSide = MailmanScreenRight;
        _mailman.zPosition = zPos_Mailman;
    }
    return _mailman;
}

- (LRButton*) pauseButton
{
    if (!_pauseButton) {
        _pauseButton = [[LRButton alloc] initWithImageNamedNormal:@"Pause_Selected.png" selected:@"Pause_Unselected.png"];
        [_pauseButton setScale:.7];
        [_pauseButton setTouchUpInsideTarget:self action:@selector(pauseButtonPressed)];
        _pauseButton.position = CGPointMake(0 - SCREEN_WIDTH/2 + _pauseButton.size.width/2, SCREEN_HEIGHT/2 - self.healthSection.size.height - _pauseButton.size.height/2);
        _pauseButton.zPosition = zPos_PauseButton;
    }
    return _pauseButton;

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
        //Reset the falling letters list
        [self.letterSlots resetSlots];
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

- (void) dropLetter
{
    LRFallingEnvelope *envelope = [LRLetterBlockGenerator createRandomEnvelope];
    [self.letterSlots addEnvelope:envelope];
    [self addChild:envelope];
    [envelope dropEnvelopeWithSwing];
}

#pragma mark - Board Properties

- (CGPoint) flungEnvelopeDestination
{
    return [self.mailman letterEntryPoint];
}

@end
