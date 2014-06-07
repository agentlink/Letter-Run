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
#import "LRSharedTextureCache.h"

static const CGFloat kLRHealthSectionInitialDropTime = 35.0;
static const CGFloat kLRHealthSectionStartPercentYellow = .50;

@interface LRHealthBarColoredBackground : SKSpriteNode
@end

@interface LRHealthBarColoredMovingSection : SKSpriteNode
@end

@interface LRHealthBarMovingSprite : SKSpriteNode
@property (nonatomic,readwrite) NSUInteger healthbarDropTime;
@property (nonatomic,readonly) CGFloat percentProgress;
- (void)startColoredBarFall;
- (void)increaseColoredBarByDistance:(CGFloat)distance;
- (void)restartHealthBar;
@end


@interface LRHealthSection ()
///The container object for all health bar objects whose color is affected by the health bar's position
@property (nonatomic, strong) LRHealthBarMovingSprite *coloredBar;
///The background color of the health bar
@property (nonatomic, strong) SKSpriteNode *healthBarBackground;
///The layer around the health bar
@property (nonatomic, strong) SKSpriteNode *healthBarSkin;
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

- (LRHealthBarMovingSprite *)coloredBar {
    if (!_coloredBar) {
        _coloredBar = [[LRHealthBarMovingSprite alloc] initWithColor:[LRColor healthBarColorGreen] size:self.size];
        _coloredBar.healthbarDropTime = [self _healthBarDropTime];
    }
    return _coloredBar;
}

- (SKSpriteNode *)healthBarBackground {
    if (!_healthBarBackground) {
        _healthBarBackground = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:self.size];
    }
    return _healthBarBackground;
}

- (SKSpriteNode *)healthBarSkin {
    if (!_healthBarSkin) {
        SKTexture *texture = [[LRSharedTextureCache shared] textureForName:@"healthSection-background"];
        _healthBarSkin = [SKSpriteNode spriteNodeWithTexture:texture];
        _healthBarSkin.xScale = (self.size.width / _healthBarSkin.size.width);
        _healthBarSkin.yScale = _healthBarSkin.xScale;
    }
    return _healthBarSkin;
}

#pragma mark - Public Functions

- (void)addScore:(NSInteger)wordScore;
{
    CGFloat shiftDistance = [self _healthBarDistanceForScore:wordScore];
    [self.coloredBar increaseColoredBarByDistance:shiftDistance];
}

- (CGFloat) percentHealth
{
    return self.coloredBar.percentProgress;
}


#pragma mark - LRGameStateDelegate Methods

- (void)gameStateNewGame
{
    [self.coloredBar restartHealthBar];
    [self.coloredBar startColoredBarFall];
}


#pragma mark - Private Methods

- (CGFloat)_healthBarDistanceForScore:(NSInteger)score
{
    CGFloat baseDistancePerLetter = self.size.width / kLRHealthSectionInitialDropTime;
    CGFloat wordDistance = (score * baseDistancePerLetter) / kLRScoreManagerScorePerLetter;
    return wordDistance;
}

- (CGFloat)_healthBarDropTime
{
    return kLRHealthSectionInitialDropTime;
}
@end


#pragma mark - LRHealthBarMovingSprite

static NSString * const kLRHealthBarColoredContainerFallAction = @"Health bar falling action";
static NSString * const kLRHealthBarColoredContainerGainAction = @"Health bar gaining action";

@interface LRHealthBarMovingSprite ()
@property (nonatomic,strong) SKSpriteNode *shadedSection;
@property (nonatomic,strong) SKSpriteNode *movingBar;
@end

@implementation LRHealthBarMovingSprite

#pragma mark - Set Up

- (id) initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size])
    {
        [self addChild:self.shadedSection];
        [self addChild:self.movingBar];
        self.color = [LRHealthBarMovingSprite _colorForPercentHealth:0.0];
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

- (void)setPosition:(CGPoint)position
{
    self.movingBar.position = position;
    self.color = [LRHealthBarMovingSprite _colorForPercentHealth:self.percentProgress];
}

- (CGPoint)position
{
    return self.movingBar.position;
}

- (NSUInteger)healthbarDropTime
{
    NSAssert(_healthbarDropTime > 0, @"Health bar drop time cannot be 0");
    return _healthbarDropTime;
}

#pragma mark - Public Methods

- (void)startColoredBarFall
{
    CGFloat distance = self.size.width + self.position.x;
    CGFloat duration = distance/self.size.width * self.healthbarDropTime;
    __block CGFloat lastElapsedTime = 0.0;
    SKAction *moveHealthbar = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        NSAssert(node == self, @"Move health bar action should only be run on self");
        CGFloat timeDiff = elapsedTime - lastElapsedTime;
        lastElapsedTime = elapsedTime;
        CGFloat dist = distance * timeDiff/duration;
        self.position = CGPointMake(self.position.x - dist, self.position.y);
    }];
    
    SKAction *completion = [SKAction runBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_GAME_OVER object:nil];
    }];
    SKAction *moveWithCompletion = [SKAction sequence:@[moveHealthbar, completion]];
    [self runAction:moveWithCompletion withKey:kLRHealthBarColoredContainerFallAction];
}

- (void)increaseColoredBarByDistance:(CGFloat)distance
{
    distance = MIN(distance, -self.position.x);
    //#toy
    CGFloat maxTime = 1.2;
    CGFloat duration = distance/self.size.width * maxTime;
    
    //Cancel the falling action, run the increase action, and restart the falling action
    CGFloat originalX = self.position.x;
    SKAction *moveHealthBar = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        CGFloat newX = originalX + (elapsedTime/duration) * distance;
        self.position = CGPointMake(newX, self.position.y);
    }];
    moveHealthBar.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *completion = [SKAction runBlock:^{
        [self startColoredBarFall];
    }];
    [self removeActionForKey:kLRHealthBarColoredContainerFallAction];
    [self runAction:[SKAction sequence:@[moveHealthBar, completion]] withKey:kLRHealthBarColoredContainerGainAction];
}

- (void)restartHealthBar
{
    self.position = CGPointZero;
}

- (CGFloat)percentProgress
{
    CGFloat startX = 0.0;
    CGFloat endX = -self.size.width;
    CGFloat progressX = self.position.x;
    
    CGFloat percent = progressX/(endX - startX);
    percent = MIN(1.00, percent);
    percent = MAX(0.00, percent);
    return percent;
}

#pragma Private Methods

+ (LRColor *)_colorForPercentHealth:(CGFloat)percent
{
    NSAssert(percent >= 0.0 && percent <= 1.0, @"Percent should be between 0 and 1");
    CGFloat relativePercent;
    LRColor *newColor;
    if (percent < kLRHealthSectionStartPercentYellow) {
        relativePercent = percent/kLRHealthSectionStartPercentYellow;
        newColor = [LRColor colorBetweenStartColor:[LRColor healthBarColorGreen]
                                       andEndColor:[LRColor healthBarColorYellow]
                                           percent:relativePercent];
    }
    else {
        relativePercent = (percent - kLRHealthSectionStartPercentYellow) / (1.0 - kLRHealthSectionStartPercentYellow);
        newColor = [LRColor colorBetweenStartColor:[LRColor healthBarColorYellow]
                                       andEndColor:[LRColor healthBarColorRed]
                                           percent:relativePercent];
    }
    return newColor;
}

@end

