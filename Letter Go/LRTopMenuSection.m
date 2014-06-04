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

@interface LRScoreControlColorScore : SKSpriteNode
- (id)initWithPaperColor:(LRPaperColor)paperColor;

@property (readonly) LRPaperColor paperColor;
@property (nonatomic) NSUInteger colorScore;
@property (nonatomic, strong) SKLabelNode *colorScoreLabel;
@end

@interface LRMissionControlSection : SKSpriteNode <LRScoreManagerDelegate>
@property (nonatomic, strong) SKLabelNode *scoreLabel;
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
    SKTexture *scoreControlTexture = [[LRSharedTextureCache shared] textureForName:@"topMenuSection-missionControl"];
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
        [self addChild:self.scoreLabel];
        [self _setUpEnvelopeScores];
        [LRScoreManager shared].delegate = self;
    }
    return self;
}

- (SKLabelNode *)scoreLabel
{
    if (!_scoreLabel) {
        CGFloat fontSize = 75;
        LRFont *scoreLabelFont = [LRFont displayTextFontWithSize:fontSize];
        CGFloat rightMargin = -10.0;
        CGFloat topMargin = -15.0;
        
        
        _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:scoreLabelFont.familyName];
        _scoreLabel.fontSize = fontSize;
        _scoreLabel.fontColor = [LRColor blackColor];
        _scoreLabel.position = CGPointMake(-_scoreLabel.frame.size.width/2 + rightMargin,
                                           -_scoreLabel.frame.size.height/2 + topMargin);
        _scoreLabel.text = [self _stringForNumPoints:0];
        [_scoreLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeTop];
        [_scoreLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeRight];
    }
    return _scoreLabel;
}

- (void)_setUpEnvelopeScores
{
    CGFloat vertMargin = -15;
    CGFloat leftMargin = 10;
    CGFloat scoreXPos = -self.size.width + leftMargin;

    self.yellowScore = [[LRScoreControlColorScore alloc] initWithPaperColor:kLRPaperColorYellow];
    self.blueScore = [[LRScoreControlColorScore alloc] initWithPaperColor:kLRPaperColorBlue];
    self.pinkScore = [[LRScoreControlColorScore alloc] initWithPaperColor:kLRPaperColorPink];
    NSArray *scoreLabels = @[self.yellowScore, self.blueScore, self.pinkScore];
    
    CGFloat marginedHeight = self.size.height - 2 * vertMargin - self.yellowScore.size.height;
    int count = 0;
    for (LRScoreControlColorScore *scoreLabel in scoreLabels)
    {
        CGFloat scoreYPos = marginedHeight * -count/[scoreLabels count] + -scoreLabel.size.height/2 + vertMargin;
        scoreLabel.position = CGPointMake(scoreXPos, scoreYPos);
        count ++;
        [self addChild:scoreLabel];
    }
}
- (NSString *)_stringForNumPoints:(NSUInteger)points
{
    return [NSString stringWithFormat:@"%u pts.", (unsigned)points];
}

#pragma mark - Score Manager Delegate Functions
- (void)scoreDidChange
{
    self.scoreLabel.text = [NSString stringWithFormat: @"%u pts.", (unsigned)[[LRScoreManager shared] score]];
    self.yellowScore.colorScore = [[LRScoreManager shared] numYellowEnvelopes];
    self.blueScore.colorScore = [[LRScoreManager shared] numBlueEnvelopes];
    self.pinkScore.colorScore = [[LRScoreManager shared] numPinkEnvelopes];
}
@end


#pragma mark - LRScoreControlColorScore -
@implementation LRScoreControlColorScore

- (id)initWithPaperColor:(LRPaperColor)paperColor
{
    if (self = [super init])
    {
        _paperColor = paperColor;
        [self addChild:self.colorScoreLabel];
    }
    return self;
}

- (SKLabelNode *)colorScoreLabel
{
    if (!_colorScoreLabel) {
        CGFloat fontSize = 50;
        LRFont *font = [LRFont displayTextFontWithSize:fontSize];
        
        _colorScoreLabel = [SKLabelNode labelNodeWithFontNamed:font.familyName];
        _colorScoreLabel.fontColor = [LRColor secondaryColorForPaperColor:self.paperColor];
        _colorScoreLabel.fontSize = fontSize;
        _colorScoreLabel.text = [self _scoreStringWithScore:0];
        [_colorScoreLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [_colorScoreLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    }
    return _colorScoreLabel;
}

- (void)setColorScore:(NSUInteger)colorScore
{
    _colorScore = colorScore;
    self.colorScoreLabel.text = [self _scoreStringWithScore:_colorScore];
}

- (NSString *)_scoreStringWithScore:(NSUInteger)score
{
    NSString *envelopeStr = (score != 1) ? @"envelopes" : @"envelope";
    NSString *labelText = [NSString stringWithFormat:@"%u %@", (unsigned)score, envelopeStr];
    return labelText;
}

- (CGSize)size
{
    return self.colorScoreLabel.frame.size;
}

@end



