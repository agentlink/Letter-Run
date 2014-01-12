//
//  LRHealthSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRHealthSection.h"
#import "LRScoreManager.h"
#import "LRDifficultyManager.h"
#import "LRGameStateManager.h"
#import "LRFallingEnvelope.h"

#define HEALTHBAR_WIDTH             SCREEN_WIDTH

static const float kHealthBarRightMostEdgePos = 0.0;

@interface LRHealthSection ()
@property (nonatomic, strong) SKSpriteNode *healthBar;
@property NSTimeInterval initialTime;
@end

@implementation LRHealthSection

- (void) createSectionContent
{
    //The color will be replaced by a health bar sprite
    [self addChild:self.healthBar];
    self.initialTime = kGameLoopResetValue;
    [self setUpNotifications];

}

- (void) setUpNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartHealthBar) name:GAME_STATE_NEW_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unpauseGame) name:GAME_STATE_CONTINUE_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailmanHitWithLetterBlock:) name:NOTIFICATION_ENVELOPE_HIT_MAILMAN object:nil];
}

- (SKSpriteNode*) healthBar {
    if (!_healthBar) {
        _healthBar = [SKSpriteNode spriteNodeWithColor:[LRColor healthBarColor] size:self.size];
    }
    return _healthBar;
}

- (void) update:(NSTimeInterval)currentTime
{
    //If the game is over, do nothing
    if ([[LRGameStateManager shared] isGameOver] || [[LRGameStateManager shared] isGamePaused]) {
        return;
    }
    //If the health bar has been toggled off, reset it
    else if (![[LRDifficultyManager shared] healthBarFalls]) {
        self.initialTime = kGameLoopResetValue;
    }
    else if (self.initialTime == kGameLoopResetValue) {
        self.initialTime = currentTime;
    }
    else {
        [self shiftHealthBarWithTimeInterval:currentTime];
    }
    
}

/// This function animates the health bar
- (void) shiftHealthBarWithTimeInterval: (NSTimeInterval)currentTime {
    //Calculate the distance the health bar should move...
    float healthBarDropPerSecond = HEALTHBAR_WIDTH/[[LRDifficultyManager shared] healthBarDropTime];
    float timeInterval = currentTime - self.initialTime;
    float healthBarXShift = timeInterval * healthBarDropPerSecond;
    
    //...and move it
    CGPoint healthBarPos = self.healthBar.position;
    healthBarPos.x -= healthBarXShift;
    self.healthBar.position = healthBarPos;

    //Update the last time interval
    self.initialTime = currentTime;
    
    //Check if the bar has moved off screen and if so, post that the game is over
    CGRect barFrame = self.healthBar.frame;
    barFrame.origin = [self.parent convertPoint:barFrame.origin fromNode:self.healthBar];
    if (barFrame.origin.x < self.frame.origin.x - (2 * barFrame.size.width))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_GAME_OVER object:nil];
    }

}

- (void) addScore:(int) wordScore;
{
    float shiftDistance = [LRHealthSection healthBarDistanceForScore:wordScore];
    float newXValue = self.healthBar.position.x + shiftDistance;
    
    //The bar cannot move farther right than the right most edge
    newXValue *= (newXValue > kHealthBarRightMostEdgePos) ? 0 : 1;
    self.healthBar.position = CGPointMake(newXValue, self.healthBar.position.y);
}


+ (CGFloat) healthBarDistanceForScore:(int)score {
    float baseDistancePerLetter = HEALTHBAR_WIDTH / [[LRDifficultyManager shared] healthInFallenEnvelopes];
    float scorePerLetter = [[LRDifficultyManager shared] scorePerLetter];
    
    float wordDistance = (score * baseDistancePerLetter) / scorePerLetter;
    return wordDistance;
}

- (void) restartHealthBar
{
    self.healthBar.position = CGPointMake(0, self.healthBar.position.y);
    self.initialTime = kGameLoopResetValue;
}

- (CGFloat) percentHealth {
    return 100 * (HEALTHBAR_WIDTH + self.healthBar.position.x)/HEALTHBAR_WIDTH;
}

- (void) moveHealthByPercent:(CGFloat)percent
{
    CGFloat newXPos = self.healthBar.position.x + (percent/100) * HEALTHBAR_WIDTH;
    if (newXPos > 0)
        newXPos = 0;
    else if (newXPos < 0 - HEALTHBAR_WIDTH)
        newXPos = 0 - HEALTHBAR_WIDTH;
    self.healthBar.position = CGPointMake(newXPos, self.healthBar.position.y);
}

#pragma mark - Mailman Functions

- (void) mailmanHitWithLetterBlock:(NSNotification*)notification
{
    if (![[LRDifficultyManager shared] mailmanReceivesDamage])
        return;
    LRFallingEnvelope *envelope = [(LRFallingEnvelope*)[notification userInfo] valueForKey:KEY_GET_LETTER_BLOCK];
    if (envelope.blockState == BlockState_BlockFlung)
        return;
    CGFloat damageDistance = [[LRDifficultyManager shared] mailmanHitDamage];
    self.healthBar.position = CGPointMake(self.healthBar.position.x - damageDistance, self.healthBar.position.y);
}

- (void) unpauseGame {
    self.initialTime = kGameLoopResetValue;
}

@end
