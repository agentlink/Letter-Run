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
#import "LRProgressManager.h"

//static const CGFloat kLRHealthSectionInitialDropTime = 50.0;
static const CGFloat kLRHealthSectionStartPercentYellow = .50;

@interface LRHealthBarColoredBackground : SKSpriteNode
@end

@interface LRHealthBarColoredMovingSection : SKSpriteNode
@end

@interface LRHealthBarMovingSprite : SKSpriteNode
@property (nonatomic,readonly) CGFloat healthBarDropTime;
@property (nonatomic,readonly) CGFloat percentProgress;
- (void)startColoredBarFall;
- (void)increaseColoredBarByDistance:(CGFloat)distance restartMovement:(BOOL)restartMovement;
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

- (id) initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (!self) return self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_levelFinished) name:GAME_STATE_FINISHED_LEVEL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_levelStarted) name:GAME_STATE_STARTED_LEVEL object:nil];
    
    [self addChild:self.healthBarBackground];
    [self addChild:self.coloredBar];
    [self addChild:self.healthBarSkin];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties Accessors

- (LRHealthBarMovingSprite *)coloredBar {
    if (!_coloredBar) {
        _coloredBar = [[LRHealthBarMovingSprite alloc] initWithColor:[UIColor healthBarColorGreen] size:self.size];
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
        SKTexture *texture = [[LRSharedTextureCache shared] textureWithName:@"healthSection-background"];
        _healthBarSkin = [SKSpriteNode spriteNodeWithTexture:texture];
        _healthBarSkin.xScale = (self.size.width / _healthBarSkin.size.width);
        _healthBarSkin.yScale = _healthBarSkin.xScale;
    }
    return _healthBarSkin;
}

#pragma mark - Public Methods

- (void)addScore:(NSInteger)wordScore;
{
//    CGFloat shiftDistance = [self _healthBarDistanceForScore:wordScore];
//    [self.coloredBar increaseColoredBarByDistance:shiftDistance];
}

- (CGFloat) percentHealth
{
    return self.coloredBar.percentProgress;
}


#pragma mark - LRGameStateDelegate Methods

- (void)gameStateNewGame
{
    [self.coloredBar restartHealthBar];
}


#pragma mark - Private Methods

- (CGFloat)_healthBarDistanceForScore:(NSInteger)score
{
    CGFloat baseDistancePerLetter = self.size.width / self.coloredBar.healthBarDropTime;
    CGFloat wordDistance = (score * baseDistancePerLetter) / kLRScoreManagerScorePerLetter;
    return wordDistance;
}

- (void)_levelFinished
{
    [self.coloredBar increaseColoredBarByDistance:self.coloredBar.size.width restartMovement:NO];
}

- (void)_levelStarted
{
    [self.coloredBar startColoredBarFall];
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
        _shadedSection = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:self.size];
        _shadedSection.alpha = .15;
    }
    return _shadedSection;
}

- (SKSpriteNode *)movingBar
{
    if (!_movingBar) {
        _movingBar = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:self.size];
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

#pragma mark - Public Methods

- (void)startColoredBarFall
{
    CGFloat distance = self.size.width + self.position.x;
    CGFloat duration = distance/self.size.width * self.healthBarDropTime;
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

- (void)increaseColoredBarByDistance:(CGFloat)distance restartMovement:(BOOL)restartMovement
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
    SKAction *increaseAction;
    if (restartMovement)
    {
        SKAction *completion = [SKAction runBlock:^{
            [self startColoredBarFall];
        }];
        increaseAction = [SKAction sequence:@[moveHealthBar, completion]];
    }
    else
    {
        increaseAction = moveHealthBar;
    }
    [self removeActionForKey:kLRHealthBarColoredContainerFallAction];
    [self runAction:increaseAction withKey:kLRHealthBarColoredContainerGainAction];
}

- (void)restartHealthBar
{
    self.position = CGPointZero;
}

- (CGFloat)healthBarDropTime
{
    CGFloat dropTime = [[[LRProgressManager shared] currentMission] healthDropTime];
    return dropTime;
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

+ (UIColor *)_colorForPercentHealth:(CGFloat)percent
{
    NSAssert(percent >= 0.0 && percent <= 1.0, @"Percent should be between 0 and 1");
    CGFloat relativePercent;
    UIColor *newColor;
    if (percent < kLRHealthSectionStartPercentYellow) {
        relativePercent = percent/kLRHealthSectionStartPercentYellow;
        newColor = [UIColor colorBetweenStartColor:[UIColor healthBarColorGreen]
                                       andEndColor:[UIColor healthBarColorYellow]
                                           percent:relativePercent];
    }
    else {
        relativePercent = (percent - kLRHealthSectionStartPercentYellow) / (1.0 - kLRHealthSectionStartPercentYellow);
        newColor = [UIColor colorBetweenStartColor:[UIColor healthBarColorYellow]
                                       andEndColor:[UIColor healthBarColorRed]
                                           percent:relativePercent];
    }
    return newColor;
}

@end

