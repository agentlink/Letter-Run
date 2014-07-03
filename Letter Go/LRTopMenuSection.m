//
//  LRTopMenuSection.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/31/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRTopMenuSection.h"
#import "LRSharedTextureCache.h"
#import "LRButton.h"
#import "LRGameStateManager.h"
#import "LRScoreManager.h"
#import "LRValueLabelNode.h"
#import "LRProgressManager.h"
#import "LRLevelManager.h"
#import "LRMath.h"
#import "LRShadowRoundedRect.h"
#import "LRPositionConstants.h"

static NSString * const kLRScoreControllerName = @"score controller";
static CGFloat const kLRScoreControllerPaperColorVertOffset = 10.0;

@interface LRScoreControllerPaperColor : SKSpriteNode
- (id)initWithPaperColor:(LRPaperColor)paperColor;
- (void)updateScoreAnimated:(BOOL)animated;

@property (readonly) LRPaperColor paperColor;
@property (nonatomic) NSUInteger colorScore;
@property (nonatomic, strong) LRValueLabelNode *colorScoreLabel;
@end

@interface LRMissionControlSection : SKSpriteNode <LRScoreManagerDelegate>
- (void)increasedLevel;

@property (nonatomic, weak) NSNumber *scoreNum;
@property (nonatomic, strong) NSArray *scoreControllerArray;
@property (nonatomic, strong) LRMission *mission;
@property (nonatomic, strong) LRButton *okButton;
@end

@interface LRMisisonControlLevelLabel : LRShadowRoundedButton
@property (nonatomic) NSUInteger level;
@end

@interface LRTopMenuSection ()
@property (nonatomic, strong) LRMissionControlSection *missionControlSprite;
@property (nonatomic, strong) LRShadowRoundedButton *pauseButton;
@property (nonatomic, strong) LRMisisonControlLevelLabel *levelLabel;
@end


@implementation LRTopMenuSection

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_gameStarted) name:GAME_STATE_NEW_GAME object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_increasedLevel) name:GAME_STATE_FINISHED_LEVEL object:nil];
        
        self.color = [UIColor whiteColor];
        self.zPosition = zPos_TopSection;
        
        //mission control image
        
        SKTexture *scoreControlTexture = [[LRSharedTextureCache shared] textureWithName:@"topMenuSection-missionControl"];
        self.missionControlSprite = [[LRMissionControlSection alloc] initWithTexture:scoreControlTexture];
        self.missionControlSprite.anchorPoint = CGPointMake(0.5, 0.5);
        [self addChild:self.missionControlSprite];
        
        //pause button
        SKLabelNode *pauseLabel = [SKLabelNode labelNodeWithFontNamed:[LRFont displayTextFontWithSize:10].familyName];
        pauseLabel.text = @"I I";
        pauseLabel.fontColor = [UIColor textDarkBlue];
        CGFloat childMargin = 9.0;

        LRShadow *pauseShadow = [LRShadow shadowWithHeight:5.0 color:[UIColor buttonDarkBlue] top:NO radius:3.5];
        self.pauseButton = [[LRShadowRoundedButton alloc] initWithColor:[UIColor buttonLightBlue] size:CGSizeMake(26, 32) shadow:pauseShadow];
        self.pauseButton.anchorPoint = CGPointMake(0.5, 1.0);
        self.pauseButton.position = CGPointMake((self.pauseButton.size.width - self.size.width)/2 + childMargin, (self.size.height - self.missionControlSprite.size.height + self.pauseButton.size.height)/2);
        self.pauseButton.titleLabel = pauseLabel;
        [self addChild:self.pauseButton];
        [_pauseButton setTouchUpInsideTarget:self action:@selector(pauseButtonPressed)];
        
        //level label
        LRShadow *levelShadow = [LRShadow shadowWithHeight:5.0 color:[UIColor buttonDarkBlue] top:YES radius:3.5];
        self.levelLabel = [[LRMisisonControlLevelLabel alloc] initWithColor:[UIColor buttonLightBlue] size:CGSizeMake(27, 54) shadow:levelShadow];
        self.levelLabel.anchorPoint = CGPointMake(1.0, 1.0);
        self.levelLabel.position = CGPointMake((self.size.width - self.levelLabel.size.width)/2- childMargin, self.pauseButton.position.y - levelShadow.height * 2);
        [self addChild:self.levelLabel];
        
        //preload the fonts
        LRScoreControllerPaperColor *dummy = [[LRScoreControllerPaperColor alloc] initWithPaperColor:kLRPaperColorPink];
        (void)dummy;
    }
    return self;
}

- (void)pauseButtonPressed
{
    NSString *notifName = ([[LRGameStateManager shared] isGamePaused]) ? GAME_STATE_CONTINUE_GAME : GAME_STATE_PAUSE_GAME;
    NSLog(@"%@", notifName);
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:nil];
}

- (void)_gameStarted
{
    self.missionControlSprite.mission = [[LRProgressManager shared] currentMission];
}

- (void)_increasedLevel
{
    [self.missionControlSprite increasedLevel];
    self.levelLabel.level = [[LRProgressManager shared] level];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

#pragma mark - LRScoreControlSprite
static CGFloat const kLRScoreControlSpriteWidth = 230.0;
static CGFloat const kLRScoreControlSpriteHeight = 88.0;
@implementation LRMissionControlSection

- (id)initWithTexture:(SKTexture *)texture
{
 
    if (self = [super initWithTexture:texture])
    {
        self.size = CGSizeMake(kLRScoreControlSpriteWidth, kLRScoreControlSpriteHeight);
        self.anchorPoint = CGPointMake(1, 1);
        [LRScoreManager shared].delegate = self;
        [self addChild:self.okButton];
        self.okButton.hidden = YES;
    }
    return self;
}

- (LRButton *)okButton
{
    if (!_okButton)
    {
        _okButton = [LRButton okButtonWithFontSize:20];
        _okButton.anchorPoint = CGPointMake(0.5, 0);
        _okButton.position = CGPointMake(0, -self.size.height/2);
        [_okButton setTouchUpInsideTarget:self action:@selector(_okTapped)];
    }
    return _okButton;
}

- (void)setMission:(LRMission *)mission
{
    _mission = mission;
    NSArray *paperColors = [mission paperColors];
    NSMutableArray *scoreControllers = [NSMutableArray new];
    for (NSNumber *paperNum in paperColors)
    {
        LRPaperColor color = [paperNum integerValue];
        LRScoreControllerPaperColor *score = [[LRScoreControllerPaperColor alloc] initWithPaperColor:color];
        [scoreControllers addObject:score];
    }
    self.scoreControllerArray = scoreControllers;
    SKAction *showMission = [self _missionControlDropAnimationWithDuration:1.0];
    self.okButton.alpha = 0.0;
    self.okButton.hidden = NO;
    [self runAction:showMission];
}

- (void)setScoreControllerArray:(NSArray *)scoreControllerArray
{
    [self _removeCurrentScoreControllers];
    _scoreControllerArray = scoreControllerArray;
    if (!scoreControllerArray || [scoreControllerArray count] == 0)
        return;
    
    CGFloat xOffset = -self.size.width * 1/self.xScale;
    CGFloat scoreYPos = kLRScoreControllerPaperColorVertOffset;
    NSInteger count = [scoreControllerArray count];
    for (int i = 0; i < count; i++)
    {
        LRScoreControllerPaperColor *scoreCont = self.scoreControllerArray[i];
        CGFloat scoreXPos = (-xOffset) * (i+1)/(count + 1) + xOffset/2;//([scoreControllerArray count] + 1) + xOffset;
        scoreCont.position = CGPointMake(scoreXPos, scoreYPos);
        scoreCont.name = kLRScoreControllerName;
        [self addChild:scoreCont];
    }
}


- (void)increasedLevel
{
    self.mission = [[LRProgressManager shared] currentMission];
}

#pragma mark - Private Methods

- (void)_removeCurrentScoreControllers
{
    //TODO: animate this removal
    [self enumerateChildNodesWithName:kLRScoreControllerName usingBlock:^(SKNode *node, BOOL *stop) {
        [self removeChildrenInArray:@[node]];
    }];
}

- (void)_okTapped
{
    SKAction *moveUp = [self _missionControlUpWithDuration:.4];
    [self runAction:moveUp];
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_STARTED_LEVEL object:nil];
    self.okButton.hidden = YES;
}

- (NSString *)_stringForNumPoints:(NSUInteger)points
{
    return [NSString stringWithFormat:@"%u pts.", (unsigned)points];
}

#pragma mark Animations

- (SKAction *)_missionControlDropAnimationWithDuration:(CGFloat)duration
{
    __block BOOL crossedVertex;
    __block CGFloat endY = -220.0;
    __block CGFloat topScale = 0;
    CGFloat overshoot = 30;
    CGPoint yIntercept= CGPointMake(0, self.position.y);
    CGPoint vertex = CGPointMake(duration/2, endY - overshoot);
    double a = (yIntercept.y - vertex.y)/pow((yIntercept.x - vertex.x), 2);

    CGFloat originalHeight = kLRScoreControlSpriteHeight;
    
    SKAction *parabola = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        CGFloat y = quadratic_equation_y(a, vertex, elapsedTime);
        crossedVertex = (elapsedTime > vertex.x);
        
        //If the function is over
        if (crossedVertex && y > endY)
        {
            node.position = CGPointMake(node.position.x, endY);
            for (LRScoreControllerPaperColor *scoreCont in self.scoreControllerArray)
            {
                scoreCont.alpha = 1;
            }
        }
        else {
            //Scale
            CGFloat growthPoint = .4;
            CGFloat scale = 0;
            if (y < endY * growthPoint)
            {
                CGFloat maxScale = .05;
                if (!crossedVertex)
                {
                    scale = (maxScale * growthPoint) * (endY * growthPoint - y)/overshoot;
                    topScale = scale;
                }
                else
                {
                    scale = topScale * (endY - y)/overshoot;
                }
                self.xScale = 1 + scale;
                self.yScale = 1 + scale;
            }
            
            
            //Height expansion + Fade in
            CGFloat endHeight = 250.0;
            CGFloat endHeightDiff = endHeight - originalHeight;
            CGFloat newHeight = originalHeight + endHeightDiff * MIN(elapsedTime/vertex.x, 1.0);
            CGFloat alpha =  1 - (endY - y)/endY;

            //Envelopes
            self.size = CGSizeMake(self.size.width, newHeight);
            for (LRScoreControllerPaperColor *scoreCont in self.scoreControllerArray)
            {
                CGFloat scoreY = (self.size.height - originalHeight)/2 * 1/self.yScale;
                scoreCont.position = CGPointMake(scoreCont.position.x,scoreY);
                //only change the alpha if it's 0
                if (scoreCont.alpha != 1.0)
                {
                    scoreCont.alpha = alpha;
                }
            }
            
            //OK button
            self.okButton.position = CGPointMake(self.okButton.position.x, -self.size.height/2 * 1/self.yScale);
            self.okButton.alpha = alpha;

            node.position = CGPointMake(node.position.x, y);
        }
    }];
    return parabola;
}

- (SKAction *)_missionControlUpWithDuration:(CGFloat)duration
{
    CGFloat originalHeight = self.size.height;
    CGPoint originalPostion = self.position;
    CGPoint endPosition = CGPointZero;
    SKAction *action = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime)
    {
        CGFloat yPos = originalPostion.y + (endPosition.y - originalPostion.y) * (elapsedTime/duration);
        CGFloat height = originalHeight - (originalHeight - kLRScoreControlSpriteHeight) * (elapsedTime/duration);
        self.position = CGPointMake(self.position.x, yPos);
        self.size = CGSizeMake(self.size.width, height);
        
        for (LRScoreControllerPaperColor *scoreCont in self.scoreControllerArray)
        {
            CGFloat scoreY = (self.size.height - kLRScoreControlSpriteHeight)/2 + (elapsedTime/duration) *kLRScoreControllerPaperColorVertOffset;
            scoreCont.position = CGPointMake(scoreCont.position.x,scoreY);
            
        }
    }];
    action.timingMode = SKActionTimingEaseInEaseOut;
    return action;
}

#pragma mark - Score Manager Delegate Functions
- (void)changeScoreWithAnimation:(BOOL)animated
{
    for (LRScoreControllerPaperColor *scoreCont in self.scoreControllerArray)
    {
        [scoreCont updateScoreAnimated:animated];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


#pragma mark - LRScoreControlColorScore -

@implementation LRScoreControllerPaperColor
{
    SKSpriteNode *_envSprite;
}
- (id)initWithPaperColor:(LRPaperColor)paperColor
{
    if (self = [super init])
    {
        _paperColor = paperColor;
        
        NSString *envSpriteName = [LRMovingEnvelope stringFromPaperColor:paperColor open:YES];
        _envSprite = [[SKSpriteNode alloc] initWithTexture:[[LRSharedTextureCache shared] textureWithName:envSpriteName]];
        _envSprite.size = CGSizeMake(40.0, 48.0);
        [_envSprite addChild:self.colorScoreLabel];
        
        self.colorScoreLabel.position = CGPointMake(0, -7);
        [self addChild:_envSprite];
        
        self.alpha = 0.0;
    }
    return self;
}

- (void)updateScoreAnimated:(BOOL)animated
{
    [self setColorScore:[[LRProgressManager shared] scoreLeftForPaperColor:self.paperColor] animated:animated];
}

- (SKLabelNode *)colorScoreLabel
{
    if (!_colorScoreLabel) {
        CGFloat fontSize = 40;
        LRFont *font = [LRFont displayTextFontWithSize:fontSize];
        
        _colorScoreLabel = [[LRValueLabelNode alloc] initWithFontNamed:font.familyName initialValue:0];
        _colorScoreLabel.fontColor = [UIColor secondaryColorForPaperColor:self.paperColor];
        _colorScoreLabel.fontSize = fontSize;
        
        [_colorScoreLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [_colorScoreLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    }
    return _colorScoreLabel;
}

- (void)setColorScore:(NSUInteger)colorScore
{
    [self setColorScore:colorScore animated:YES];
}

- (void)setColorScore:(NSUInteger)colorScore animated:(BOOL)animated
{
    _colorScore = colorScore;
    [self.colorScoreLabel updateValue:colorScore animated:animated];
}

- (CGSize)size
{
    return _envSprite.size;
}

@end


@implementation LRMisisonControlLevelLabel
{
    SKLabelNode *_levelLabel;
}

- (id)initWithColor:(UIColor *)color size:(CGSize)size shadow:(LRShadow *)shadow
{
    if (self = [super initWithColor:color size:size shadow:shadow])
    {
        SKLabelNode *levelTitle = [SKLabelNode labelNodeWithFontNamed:@"LeagueGothic-Regular"];
        _levelLabel = [SKLabelNode labelNodeWithFontNamed:@"LeagueGothic-Regular"];
        levelTitle.text = @"LEVEL";
        levelTitle.fontColor = [UIColor textDarkBlue];
        levelTitle.fontSize = 13;
        levelTitle.position = CGPointMake(0, self.size.height/2 - levelTitle.frame.size.height * 1.5);
        
        _levelLabel.fontSize = 34.0;
        _levelLabel.position = CGPointMake(0, shadow.height - (self.size.height  - _levelLabel.frame.size.height)/2);
        _levelLabel.fontColor = [UIColor textDarkBlue];
        self.level = 1;
        
        [self addChild:levelTitle];
        [self addChild:_levelLabel];
    }
    return self;
}

- (void)setLevel:(NSUInteger)level
{
    _level = level;
    _levelLabel.text = [NSString stringWithFormat:@"%i", (int)level];
}

@end



