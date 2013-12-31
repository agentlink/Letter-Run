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

@interface LRHealthSection ()
@property SKSpriteNode *healthBar;
@property NSTimeInterval initialTime;
@end

@implementation LRHealthSection

- (void) createSectionContent
{
    //The color will be replaced by a health bar sprite
    self.healthBar = [SKSpriteNode spriteNodeWithColor:[LRColor healthBarColor] size:self.size];
    [self addChild:self.healthBar];
    self.initialTime = kGameLoopResetValue;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartHealthBar) name:GAME_STATE_NEW_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unpauseGame) name:GAME_STATE_CONTINUE_GAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailmanHitWithLetterBlock:) name:NOTIFICATION_ENVELOPE_HIT_MAILMAN object:nil];

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

- (void) shiftHealthBarWithTimeInterval: (NSTimeInterval)currentTime {
    //Calculate drop rate
    float speedFactor = SCREEN_WIDTH/[[LRDifficultyManager shared] healthBarDropTime];
    self.healthBar.position = CGPointMake(self.healthBar.position.x - ((currentTime - self.initialTime) * speedFactor), self.healthBar.position.y);
    self.initialTime = currentTime;
    
    CGRect barFrame = self.healthBar.frame;
    barFrame.origin = [self.parent convertPoint:barFrame.origin fromNode:self.healthBar];
    if (barFrame.origin.x < self.frame.origin.x - (2 * barFrame.size.width))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_GAME_OVER object:nil];
    }

}

- (void) addScore:(int) wordScore;
{
    //Percent increase per hundred points
    float healthBarToScoreRatio = (SCREEN_WIDTH * [[LRDifficultyManager shared] healthPercentIncreasePer100Pts]/100) / 100;

    float newXValue = self.healthBar.position.x + (wordScore * healthBarToScoreRatio);
    
    //The bar cannot move farther left than the left most edge
    newXValue *= (newXValue > 0) ? 0 : 1;
    self.healthBar.position = CGPointMake(newXValue, self.healthBar.position.y);
}


- (void) restartHealthBar
{
    self.healthBar.position = CGPointMake(0, self.healthBar.position.y);
    self.initialTime = kGameLoopResetValue;
}

- (CGFloat) percentHealth
{
    return 100 * (SCREEN_WIDTH + self.healthBar.position.x)/SCREEN_WIDTH;
}

- (void) moveHealthByPercent:(CGFloat)percent
{
    CGFloat newXPos = self.healthBar.position.x + (percent/100) * SCREEN_WIDTH;
    if (newXPos > 0)
        newXPos = 0;
    else if (newXPos < 0 - SCREEN_WIDTH)
        newXPos = 0 - SCREEN_WIDTH;
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
