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

@interface LRScoreControlColorScore : SKSpriteNode
- (id)initWithPaperColor:(LRPaperColor)paperColor;
- (void)setColorScore:(NSUInteger)colorScore animated:(BOOL)animated;

@property (readonly) LRPaperColor paperColor;
@property (nonatomic) NSUInteger colorScore;
@property (nonatomic, strong) LRValueLabelNode *colorScoreLabel;
@end

@interface LRMissionControlSection : SKSpriteNode <LRScoreManagerDelegate>
@property (nonatomic, weak) NSNumber *scoreNum;

@property (nonatomic, strong) LRScoreControlColorScore *yellowScore;
@property (nonatomic, strong) LRScoreControlColorScore *blueScore;
@property (nonatomic, strong) LRScoreControlColorScore *pinkScore;
@end

@interface LRTopMenuSection ()
@property (nonatomic, strong) LRMissionControlSection *missionControlSprite;
@property (nonatomic, strong) LRButton *pauseButton;
@end

@implementation LRTopMenuSection

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.color = [LRColor whiteColor];
    }
    return self;
}

- (void)createSectionContent
{
    CGFloat contentMargin = self.size.width * .028;

    //mission control image
    SKTexture *scoreControlTexture = [[LRSharedTextureCache shared] textureWithName:@"topMenuSection-missionControl"];
    self.missionControlSprite = [[LRMissionControlSection alloc] initWithTexture:scoreControlTexture];
    self.missionControlSprite.xScale = .47;
    self.missionControlSprite.yScale = .47;
    self.missionControlSprite.position = CGPointMake(self.size.width/2 - contentMargin, self.size.height/2 - contentMargin);
    [self addChild:self.missionControlSprite];
    
    //pause button
    self.pauseButton = [[LRButton alloc] initWithImageNamed:@"pause-button" withDisabledOption:NO];
    self.pauseButton.anchorPoint = CGPointMake(0, 1);
    self.pauseButton.position = CGPointMake(contentMargin - self.size.width/2, self.missionControlSprite.position.y);
    [self addChild:self.pauseButton];
    [_pauseButton setTouchUpInsideTarget:self action:@selector(pauseButtonPressed)];
    
}

- (void)pauseButtonPressed
{
    NSString *notifName = ([[LRGameStateManager shared] isGamePaused]) ? GAME_STATE_CONTINUE_GAME : GAME_STATE_PAUSE_GAME;
    NSLog(@"%@", notifName);
    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:nil];
}

@end

#pragma mark - LRScoreControlSprite -

@implementation LRMissionControlSection

- (id)initWithTexture:(SKTexture *)texture
{
    if (self = [super initWithTexture:texture])
    {
        self.anchorPoint = CGPointMake(1, 1);
        [self _setUpEnvelopeScores];
        [LRScoreManager shared].delegate = self;
    }
    return self;
}

- (void)_setUpEnvelopeScores
{
    self.yellowScore = [[LRScoreControlColorScore alloc] initWithPaperColor:kLRPaperColorYellow];
    self.blueScore = [[LRScoreControlColorScore alloc] initWithPaperColor:kLRPaperColorBlue];
    self.pinkScore = [[LRScoreControlColorScore alloc] initWithPaperColor:kLRPaperColorPink];
    NSArray *scoreLabels = @[self.yellowScore, self.blueScore, self.pinkScore];

    CGFloat leftMargin = 5 + self.yellowScore.size.width/2;
    CGFloat scoreXPos = -self.size.width + leftMargin;
    CGFloat scoreYPos = -self.size.height/2;
    CGFloat xDiff = 12;

    int count = 0;
    for (LRScoreControlColorScore *scoreLabel in scoreLabels)
    {
        scoreLabel.position = CGPointMake(scoreXPos + xDiff * count, scoreYPos);
        count ++;
        scoreXPos += scoreLabel.size.width + xDiff;
        [self addChild:scoreLabel];
    }
}
- (NSString *)_stringForNumPoints:(NSUInteger)points
{
    return [NSString stringWithFormat:@"%u pts.", (unsigned)points];
}

#pragma mark - Score Manager Delegate Functions
- (void)changeScoreWithAnimation:(BOOL)animated
{
    [self.yellowScore setColorScore:[[LRProgressManager shared]scoreLeftForPaperColor: kLRPaperColorYellow] animated:animated];
    [self.blueScore setColorScore:[[LRProgressManager shared]scoreLeftForPaperColor:kLRPaperColorBlue] animated:animated];
    [self.pinkScore setColorScore:[[LRProgressManager shared]scoreLeftForPaperColor:kLRPaperColorPink] animated:animated];
}

@end


#pragma mark - LRScoreControlColorScore -
@implementation LRScoreControlColorScore
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

- (SKLabelNode *)colorScoreLabel
{
    if (!_colorScoreLabel) {
        CGFloat fontSize = 50;
        LRFont *font = [LRFont displayTextFontWithSize:fontSize];
        
        _colorScoreLabel = [[LRValueLabelNode alloc] initWithFontNamed:font.familyName initialValue:0];
        _colorScoreLabel.postValueString = [self _colorScoreLabelStringForScore:0];
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
    self.colorScoreLabel.postValueString = [self _colorScoreLabelStringForScore:colorScore];
    [self.colorScoreLabel updateValue:colorScore animated:animated];

}

- (CGSize)size
{
    return _envSprite.size;
}

- (NSString *)_colorScoreLabelStringForScore:(NSUInteger)score
{
    return @"";
//    NSString *str = score == 1 ? @" envelope" : @" envelopes";
//    return str;
}

@end



