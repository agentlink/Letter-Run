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

static const CGFloat kLRHealthSectionInitialDropTime = 20.0;
static const CGFloat kLRHealthSectionRightMostEdge = 0.0;
static const CGFloat kLRHealthSectionStartPercentYellow = .50;

@interface LRHealthBarColoredBackground : SKSpriteNode
@end

@interface LRHealthBarColoredMovingSection : SKSpriteNode
@end

@interface LRHealthBarColoredContainer : SKSpriteNode
@property (nonatomic, readwrite) NSUInteger healthbarDropTime;
- (void)startColoredBarFall;
- (void)increaseColoredBarByDistance:(CGFloat)distance;
@end


@interface LRHealthSection ()
///The container object for all health bar objects whose color is affected by the health bar's position
@property (nonatomic, strong) LRHealthBarColoredContainer *coloredBar;
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
    [self addChild:self.coloredBar];
    [self addChild:self.healthBarSkin];

}


#pragma mark - Properties Accessors

- (LRHealthBarColoredContainer *)coloredBar {
    if (!_coloredBar) {
        _coloredBar = [[LRHealthBarColoredContainer alloc] initWithColor:[LRColor healthBarColorGreen] size:self.size];
        _coloredBar.healthbarDropTime = [self _healthBarDropTime];
        [_coloredBar startColoredBarFall];
    }
    return _coloredBar;
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
    CGFloat shiftDistance = [self _healthBarDistanceForScore:wordScore];
    [self.coloredBar increaseColoredBarByDistance:shiftDistance];
}

- (CGFloat) percentHealth {
    return (self.size.width + self.healthBarColored.position.x)/self.size.width;
}

- (void)moveHealthByPercent:(CGFloat)percent
{
    CGFloat newXPos = self.healthBarColored.position.x + (percent/100) * self.size.width;
    if (newXPos > 0)
        newXPos = 0;
    else if (newXPos < 0 - self.size.width)
        newXPos = 0 - self.size.width;
    self.healthBarColored.position = CGPointMake(newXPos, self.healthBarColored.position.y);
}

#pragma mark - Private Methods
#pragma mark Health Bar Movement

- (CGFloat)_healthBarDistanceForScore:(NSInteger)score {
    float baseDistancePerLetter = self.size.width / kLRHealthSectionInitialDropTime;
    
    float wordDistance = (score * baseDistancePerLetter) / kLRScoreManagerScorePerLetter;
    return wordDistance;
}

- (void)_restartHealthBar
{
    self.healthBarColored.position = CGPointMake(0, self.healthBarColored.position.y);
    self.initialTime = kLRHealthSectionLoopResetValue;
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
                                       andEndColor:[LRColor healthBarColorRed]
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

- (void)gameStateNewGame
{
    [self _restartHealthBar];
}
- (void)gameStateUnpaused
{
    self.initialTime = kLRHealthSectionLoopResetValue;
}

@end

static NSString * const kLRHealthBarColoredContainerFallAction = @"Health bar falling action";
static NSString * const kLRHealthBarColoredContainerGainAction = @"Health bar gaining action";

@interface LRHealthBarColoredContainer ()
@property (nonatomic,strong) SKSpriteNode *shadedSection;
@property (nonatomic,strong) SKSpriteNode *movingBar;
@end

@implementation LRHealthBarColoredContainer

#pragma mark - Set Up

- (id) initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size])
    {
        [self addChild:self.shadedSection];
        [self addChild:self.movingBar];
        self.color = [LRColor healthBarColorGreen];
    }
    return self;
}

- (SKSpriteNode *)shadedSection
{
    if (!_shadedSection) {
        _shadedSection = [[SKSpriteNode alloc] initWithColor:[LRColor clearColor] size:self.size];
        _shadedSection.alpha = .15;
    }
    return _shadedSection;
}

- (SKSpriteNode *)movingBar
{
    if (!_movingBar) {
        _movingBar = [[SKSpriteNode alloc] initWithColor:[LRColor clearColor] size:self.size];
    }
    return _movingBar;
}

- (void)setColor:(UIColor *)color
{
    [super setColor:[UIColor clearColor]];
    if (_shadedSection)
        self.shadedSection.color = color;
    if (_movingBar)
        self.movingBar.color = color;
}

- (NSUInteger)healthbarDropTime
{
    NSAssert(_healthbarDropTime > 0, @"Health bar drop time cannot be 0");
    return _healthbarDropTime;
}

#pragma mark - Public Methods

- (void)startColoredBarFall
{
    CGFloat distance = self.size.width - self.position.x;
    CGFloat duration = distance/self.size.width * self.healthbarDropTime;
    SKAction *moveHealthbar = [SKAction moveToX:-self.size.width duration:duration];
    SKAction *completion = [SKAction runBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_GAME_OVER object:nil];
    }];
    SKAction *moveWithCompletion = [SKAction sequence:@[moveHealthbar, completion]];
    [self.movingBar runAction:moveWithCompletion withKey:kLRHealthBarColoredContainerFallAction];
}

- (void)increaseColoredBarByDistance:(CGFloat)distance
{
    distance = MIN(distance, self.size.width);
    //#toy
    CGFloat maxTime = 1.2;
    CGFloat duration = distance/self.size.width * maxTime;
    
    //Cancel the falling action, run the increase action, and restart the falling action
    SKAction *moveHealthbar = [SKAction moveByX:distance y:0 duration:duration];
    moveHealthbar.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *completion = [SKAction runBlock:^{
        [self startColoredBarFall];
    }];
    [self.movingBar removeActionForKey:kLRHealthBarColoredContainerFallAction];
    [self.movingBar runAction:[SKAction sequence:@[moveHealthbar, completion]] withKey:kLRHealthBarColoredContainerGainAction];
}
@end

