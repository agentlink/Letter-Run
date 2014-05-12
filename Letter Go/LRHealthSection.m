//
//  LRHealthSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRHealthSection.h"
#import "LRScoreManager.h"
#import "LRGameStateManager.h"

static const NSInteger kLRHealthSectionLoopResetValue = -1;
#define HEALTHBAR_WIDTH             SCREEN_WIDTH

static const CGFloat kLRHealthSectionInitialDropTime = 40.0;
static const CGFloat kLRHealthSectionRightMostEdge = 0.0;
static const CGFloat kLRHealthSectionStartPercentYellow = .50;

@interface LRHealthSection ()
///The background color of the health bar
@property (nonatomic, strong) SKSpriteNode *healthBarBackground;
///The shading for the health bar layer
@property (nonatomic, strong) SKSpriteNode *healthBarShadingLayer;
///The moving health bar, more brightly colored
@property (nonatomic, strong) SKSpriteNode *healthBarColored;
///The layer around the health bar
@property (nonatomic, strong) SKSpriteNode *healthBarSkin;
@property NSTimeInterval initialTime;
@end

@implementation LRHealthSection

- (void)createSectionContent
{
    //The color will be replaced by a health bar sprite
    [self addChild:self.healthBarBackground];
    [self addChild:self.healthBarShadingLayer];
    [self addChild:self.healthBarColored];
    [self addChild:self.healthBarSkin];
    self.initialTime = kLRHealthSectionLoopResetValue;
}


#pragma mark - Properties Accessors

- (SKSpriteNode *)healthBarColored {
    if (!_healthBarColored) {
        _healthBarColored = [SKSpriteNode spriteNodeWithColor:[LRColor healthBarColorGreen] size:self.size];
    }
    return _healthBarColored;
}

- (SKSpriteNode *)healthBarBackground {
    if (!_healthBarBackground) {
        _healthBarBackground = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:self.size];
    }
    return _healthBarBackground;
}

- (SKSpriteNode *)healthBarShadingLayer {
    if (!_healthBarShadingLayer) {
        _healthBarShadingLayer = [SKSpriteNode spriteNodeWithColor:[LRColor healthBarColorGreen] size:self.size];
        _healthBarShadingLayer.alpha = 0.25;
    }
    return _healthBarShadingLayer;

}

- (SKSpriteNode *)healthBarSkin {
    if (!_healthBarSkin) {
        _healthBarSkin = [SKSpriteNode spriteNodeWithImageNamed:@"healthSection-background"];
        _healthBarSkin.xScale = (SCREEN_WIDTH / 480);
    }
    return _healthBarSkin;
}

#pragma mark - Public Functions

- (void)addScore:(NSInteger)wordScore;
{
    float shiftDistance = [LRHealthSection _healthBarDistanceForScore:wordScore];
    float newXValue = self.healthBarColored.position.x + shiftDistance;
    
    //The bar cannot move farther right than the right most edge
    newXValue *= (newXValue > kLRHealthSectionRightMostEdge) ? 0 : 1;
    self.healthBarColored.position = CGPointMake(newXValue, self.healthBarColored.position.y);
}

- (CGFloat) percentHealth {
    return (HEALTHBAR_WIDTH + self.healthBarColored.position.x)/HEALTHBAR_WIDTH;
}

- (void)moveHealthByPercent:(CGFloat)percent
{
    CGFloat newXPos = self.healthBarColored.position.x + (percent/100) * HEALTHBAR_WIDTH;
    if (newXPos > 0)
        newXPos = 0;
    else if (newXPos < 0 - HEALTHBAR_WIDTH)
        newXPos = 0 - HEALTHBAR_WIDTH;
    self.healthBarColored.position = CGPointMake(newXPos, self.healthBarColored.position.y);
}

#pragma mark - Private Functions
#pragma mark Health Bar Movement

+ (CGFloat)_healthBarDistanceForScore:(NSInteger)score {
    float baseDistancePerLetter = HEALTHBAR_WIDTH / kLRHealthSectionInitialDropTime;
    
    float wordDistance = (score * baseDistancePerLetter) / kLRScoreManagerScorePerLetter;
    return wordDistance;
}

- (void)_restartHealthBar
{
    self.healthBarColored.position = CGPointMake(0, self.healthBarColored.position.y);
    self.initialTime = kLRHealthSectionLoopResetValue;
}


/// This function animates the health bar
- (void)_shiftHealthBarWithTimeInterval: (NSTimeInterval)currentTime {
    //Calculate the distance the health bar should move...
    float healthBarDropPerSecond = HEALTHBAR_WIDTH/[self _healthBarDropTime];
    float timeInterval = currentTime - self.initialTime;
    float healthBarXShift = timeInterval * healthBarDropPerSecond;
    
    //...and move it
    CGPoint healthBarPos = self.healthBarColored.position;
    healthBarPos.x -= healthBarXShift;
    self.healthBarColored.position = healthBarPos;
    
    //Update the last time interval
    self.initialTime = currentTime;
    
    //Check if the bar has moved off screen and if so, post that the game is over
    CGRect barFrame = self.healthBarColored.frame;
    barFrame.origin = [self.parent convertPoint:barFrame.origin fromNode:self.healthBarColored];
    if (barFrame.origin.x < self.frame.origin.x - (2 * barFrame.size.width))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_GAME_OVER object:nil];
    }
}
- (CGFloat)_healthBarDropTime
{
    return kLRHealthSectionInitialDropTime;
}

#pragma mark Health Bar Color Change

- (void)_updateColor
{
    CGFloat percentHealth = self.percentHealth;
    CGFloat relativePercent;
    SKColor *newColor;
    if (percentHealth > kLRHealthSectionStartPercentYellow) {
        relativePercent = 1 - (percentHealth - (1 - kLRHealthSectionStartPercentYellow))/kLRHealthSectionStartPercentYellow;
        newColor = [LRColor colorBetweenStartColor:[LRColor healthBarColorGreen]
                                       andEndColor:[LRColor healthBarColorYellow]
                                           percent:relativePercent];
    }
    else {
        relativePercent = 1 - (percentHealth / (1.0 - kLRHealthSectionStartPercentYellow));
        newColor = [LRColor colorBetweenStartColor:[LRColor healthBarColorYellow]
                                       andEndColor:[LRColor healtBarColorRed]
                                           percent:relativePercent];
    }
    [self setHealthBarColor:newColor];
}

- (void)setHealthBarColor:(SKColor *)newColor
{
    [self.healthBarColored setColor:newColor];
    [self.healthBarShadingLayer setColor:newColor];
}

- (BOOL)_healthBarFalls
{
    return YES;
}
#pragma mark - LRGameStateDelegate Methods

- (void)update:(NSTimeInterval)currentTime
{
    //If the game is over, do nothing
    if ([[LRGameStateManager shared] isGameOver] || [[LRGameStateManager shared] isGamePaused]) {
        return;
    }
    //If the health bar has been toggled off, reset it
    else if (![self _healthBarFalls]) {
        self.initialTime = kLRHealthSectionLoopResetValue;
    }
    else if (self.initialTime == kLRHealthSectionLoopResetValue) {
        self.initialTime = currentTime;
    }
    else {
        [self _shiftHealthBarWithTimeInterval:currentTime];
        [self _updateColor];
    }
}

- (void)gameStateNewGame
{
    [self _restartHealthBar];
}
- (void)gameStateUnpaused
{
    self.initialTime = kLRHealthSectionLoopResetValue;
}

@end
