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
#import "LRPositionConstants.h"

static NSString * const kLRScoreControllerName = @"score controller";

@interface LRScoreControllerPaperColor : SKSpriteNode
- (id)initWithPaperColor:(LRPaperColor)paperColor;
- (void)updateScoreAnimated:(BOOL)animated;

@property (readonly) LRPaperColor paperColor;
@property (nonatomic) NSUInteger colorScore;
@property (nonatomic, strong) LRValueLabelNode *colorScoreLabel;
@end

@interface LRMissionControlSection : SKSpriteNode <LRScoreManagerDelegate>
@property (nonatomic, weak) NSNumber *scoreNum;

@property (nonatomic, strong) NSArray *scoreControllerArray;
@property (nonatomic, strong) LRMission *mission;
@property (nonatomic, strong) LRButton *okButton;
@end

@interface LRTopMenuSection ()
@property (nonatomic, strong) LRMissionControlSection *missionControlSprite;
@property (nonatomic, strong) LRButton *pauseButton;
@end

@implementation LRTopMenuSection

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_gameStarted) name:GAME_STATE_NEW_GAME object:nil];
        
        self.color = [LRColor whiteColor];
        self.zPosition = zPos_TopSection;
        //mission control image
        SKTexture *scoreControlTexture = [[LRSharedTextureCache shared] textureWithName:@"topMenuSection-missionControl"];
        self.missionControlSprite = [[LRMissionControlSection alloc] initWithTexture:scoreControlTexture];
        self.missionControlSprite.xScale = .47;
        self.missionControlSprite.yScale = .47;
        self.missionControlSprite.anchorPoint = CGPointMake(0.5, 0.5);
        [self addChild:self.missionControlSprite];
        
        //pause button
        self.pauseButton = [[LRButton alloc] initWithImageNamed:@"pause-button" withDisabledOption:NO];
        self.pauseButton.anchorPoint = CGPointMake(0, 1);
        self.pauseButton.scale = .5;
        self.pauseButton.position = CGPointMake(-self.size.width/2, self.size.height/2);
        self.pauseButton.hidden = NO;
        [self addChild:self.pauseButton];
        [_pauseButton setTouchUpInsideTarget:self action:@selector(pauseButtonPressed)];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

#pragma mark - LRScoreControlSprite

@implementation LRMissionControlSection

- (id)initWithTexture:(SKTexture *)texture
{
    if (self = [super initWithTexture:texture])
    {
        self.color = [UIColor redColor];
        self.anchorPoint = CGPointMake(1, 1);
        [LRScoreManager shared].delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_increasedLevel) name:GAME_STATE_FINISHED_LEVEL object:nil];
        [self addChild:self.okButton];
        self.okButton.hidden = YES;

    }
    return self;
}

- (LRButton *)okButton
{
    if (!_okButton)
    {
        _okButton = [LRButton okButtonWithFontSize:40];
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
    self.okButton.hidden = NO;
    
}

- (void)setScoreControllerArray:(NSArray *)scoreControllerArray
{
    [self _removeCurrentScoreControllers];
    _scoreControllerArray = scoreControllerArray;
    if (!scoreControllerArray || [scoreControllerArray count] == 0)
        return;
    
    CGFloat xOffset = -self.size.width * 1/self.xScale;
    CGFloat yOffset = 10.0;
    CGFloat scoreYPos = yOffset;
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

#pragma mark - Private Methods

- (void)_increasedLevel
{
    self.mission = [[LRProgressManager shared] currentMission];
}

- (void)_removeCurrentScoreControllers
{
    //TODO: animate this removal
    [self enumerateChildNodesWithName:kLRScoreControllerName usingBlock:^(SKNode *node, BOOL *stop) {
        [self removeChildrenInArray:@[node]];
    }];
}

- (void)_okTapped
{
    SKAction *action = [self _missionControlDropAnimationWithDuration:1.1];
    [self runAction:action];
//    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_STARTED_LEVEL object:nil];
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
    __block CGFloat endY = -SCREEN_HEIGHT/3;
    __block CGFloat topScale = 0;
    CGFloat overshoot = 30;
    CGPoint yIntercept= CGPointMake(0, self.position.y);
    CGPoint vertex = CGPointMake(duration/2, endY - overshoot);
    double a = (yIntercept.y - vertex.y)/pow((yIntercept.x - vertex.x), 2);

    SKAction *parabola = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        CGFloat y = quadratic_equation_y(a, vertex, elapsedTime);
        crossedVertex = (elapsedTime > vertex.x);
        
        if (crossedVertex && y > endY)
        {
            node.position = CGPointMake(node.position.x, endY);
            self.xScale = .47;
            self.yScale = .47;
            for (LRScoreControllerPaperColor *scoreCont in self.scoreControllerArray)
            {
                scoreCont.alpha = 1;
            }
        }
        else {
            //Expansion
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
                self.xScale = .47 + scale;
                self.yScale = .47 + scale;
            }
            //Children alpha
            for (LRScoreControllerPaperColor *scoreCont in self.scoreControllerArray)
            {
                CGFloat alpha =  1 - (endY - y)/endY;
                scoreCont.alpha = alpha;
            }

            node.position = CGPointMake(node.position.x, y);
        }
    }];
    return parabola;
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
        _envSprite.xScale = 1.8;
        _envSprite.yScale = 1.8;
        [_envSprite addChild:self.colorScoreLabel];
        
        self.colorScoreLabel.position = CGPointMake(0, -7);

        [self addChild:_envSprite];
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
        CGFloat fontSize = 50;
        LRFont *font = [LRFont displayTextFontWithSize:fontSize];
        
        _colorScoreLabel = [[LRValueLabelNode alloc] initWithFontNamed:font.familyName initialValue:0];
        _colorScoreLabel.fontColor = [LRColor secondaryColorForPaperColor:self.paperColor];
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



