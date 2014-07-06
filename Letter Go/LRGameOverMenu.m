//
//  LRGameOverMenu.m
//  Letter Go
//
//  Created by Gabe Nicholas on 7/3/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRGameOverMenu.h"
#import "LRValueLabelNode.h"
#import "LRProgressManager.h"
#import "LRScoreManager.h"

static CGSize const kLRGameOverMenuSize = (CGSize){248.0, 355.0};
static CGFloat const kLRGameOverFontSize = 22.0;

@interface LRGameOverValueLabel : SKNode
- (id)initWithTitle:(NSString *)title initialValue:(NSInteger)initialValue;
- (void)updateValue:(NSInteger)value animated:(BOOL)animated durationPerNumber:(CGFloat)duration;
- (void)updateValue:(NSInteger)value animated:(BOOL)animated totalDuration:(CGFloat)totalDuration;
@end

@interface LRCollectedWordColoredLabel: SKNode
- (id)initWithArray:(NSArray *)array;
@end

@interface LRGameOverMenu ()
@property (nonatomic, strong) LRShadowRoundedButton *restartButton;
@property (nonatomic, weak) SKNode *presentationNode;
@property (nonatomic, weak) SKSpriteNode *dropShadow;
@end

@implementation LRGameOverMenu
{
    LRGameOverValueLabel *_levelValue;
    LRGameOverValueLabel *_wordsValue;
    LRGameOverValueLabel *_lettersValue;
    LRGameOverValueLabel *_scoreValue;
}
+ (void)presentGameOverMenuOverNode:(SKNode *)presentationNode
{
    CGFloat heightOffset = -30.0;
    LRShadow *shadow = [LRShadow shadowWithHeight:5.0 color:[UIColor buttonLightBlue] top:NO radius:5.0];
    LRGameOverMenu *gameOverMenu = [[LRGameOverMenu alloc] initWithColor:[UIColor whiteColor] size:kLRGameOverMenuSize shadow:shadow];
    gameOverMenu.position = CGPointMake(presentationNode.frame.size.width/2, presentationNode.frame.size.height/2 + heightOffset);
    gameOverMenu.zPosition = 100000.0;
    gameOverMenu.presentationNode = presentationNode;
    
    SKSpriteNode *grayShadow = [[SKSpriteNode alloc] initWithColor:[UIColor dropShadowColor] size:presentationNode.frame.size];
    grayShadow.position = CGPointMake(presentationNode.frame.size.width/2, presentationNode.frame.size.height/2);
    grayShadow.zPosition = 10000.0;
    [presentationNode addChild:grayShadow];
    [presentationNode addChild:gameOverMenu];
    
    gameOverMenu.dropShadow = grayShadow;
}

- (id)initWithColor:(UIColor *)color size:(CGSize)size shadow:(LRShadow *)shadow
{
    if (self = [super initWithColor:color size:size shadow:shadow])
    {
        
        //Title label
        CGFloat titleTopMargin = 16.0;
        SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:[UIFont lr_letterBlockFont]];
        titleLabel.fontSize = 31.0;
        titleLabel.text = [self _scoreInfoTitleText];
        titleLabel.fontColor = [UIColor textDarkBlue];
        titleLabel.position = CGPointMake(0, self.size.height/2 - titleLabel.frame.size.height - titleTopMargin);
        [self addChild:titleLabel];
        
        //Score info box
        CGFloat scoreInfoTopMargin = 16.0;
        CGFloat scoreInfoLeftMargin = 25.0;
        LRShadow *scoreInfoShadow = [LRShadow shadowWithHeight:5.0 color:[UIColor buttonDarkBlue] top:YES radius:5.0];
        LRShadowRoundedRect *scoreInfoRect = [[LRShadowRoundedRect alloc] initWithColor:[UIColor buttonLightBlue] size:CGSizeMake(99.0, 212.0) shadow:scoreInfoShadow];
        scoreInfoRect.position = CGPointMake( scoreInfoLeftMargin + scoreInfoRect.size.width/2 + self.frame.origin.x, titleLabel.position.y - scoreInfoRect.size.height/2 - scoreInfoTopMargin);
        [self addChild:scoreInfoRect];
        
        //Score labels
        CGFloat labelLeftMargin = 8.0;
        _levelValue = [[LRGameOverValueLabel alloc] initWithTitle:@"Level: " initialValue:[[LRProgressManager shared] level]];
        _wordsValue = [[LRGameOverValueLabel alloc] initWithTitle:@"Words: " initialValue:0];
        _lettersValue = [[LRGameOverValueLabel alloc] initWithTitle:@"Letters: " initialValue:0];
        
        NSArray *scoreLabels = @[_levelValue, _wordsValue, _lettersValue];
        CGFloat topMargin = scoreInfoShadow.height;
        CGFloat betweenY = 5.0;
        CGFloat yVal = scoreInfoRect.size.height/2 - topMargin;
        CGFloat labelX = -scoreInfoRect.size.width/2 + labelLeftMargin;

        for (SKNode *label in scoreLabels)
        {
            yVal -= label.frame.size.height + betweenY;
            label.position = CGPointMake(labelX, yVal);
            [scoreInfoRect addChild:label];
        }
        
        //best word
        if ([[[LRScoreManager shared] highestScoringWord] count] != 0)
        {
            CGFloat bestWordYOffset = 10.0;
            CGFloat bestWordY = _lettersValue.frame.origin.y - bestWordYOffset;
            SKLabelNode *bestWord = [LRGameOverMenu _gameOverLabelNodeWithText:@"Best Word:"];
            bestWord.position = CGPointMake(labelX, bestWordY);
            [scoreInfoRect addChild:bestWord];
            
            LRCollectedWordColoredLabel *coloredLabel = [[LRCollectedWordColoredLabel alloc] initWithArray:[[LRScoreManager shared] highestScoringWord]];
            coloredLabel.position = CGPointMake(bestWord.position.x, bestWord.position.y - coloredLabel.frame.size.height);
            [scoreInfoRect addChild:coloredLabel];
        }
        
        //score
        CGFloat scoreBottomMargin = 22.0;
        SKLabelNode *scoreLabel = [LRGameOverMenu _gameOverLabelNodeWithText:@"Score:"];
        _scoreValue = [[LRGameOverValueLabel alloc] initWithTitle:nil initialValue:0];
        
        _scoreValue.position = CGPointMake(labelX, -scoreInfoRect.size.height/2 + scoreBottomMargin);
        scoreLabel.position = CGPointMake(labelX, _scoreValue.position.y + _scoreValue.frame.size.height);
        [scoreInfoRect addChild:_scoreValue];
        [scoreInfoRect addChild:scoreLabel];
        
        //restart button
        CGFloat restartMargin = shadow.height + 13.0;
        self.restartButton = [[LRShadowRoundedButton alloc] initWithColor:[UIColor buttonLightBlue] size:CGSizeMake(50.0, 54.0) shadow:[LRShadow shadowWithHeight:5.0 color:[UIColor buttonDarkBlue] top:NO radius:5.0]];
        [self.restartButton setTouchUpInsideTarget:self action:@selector(_close)];
        self.restartButton.position = CGPointMake(0, (-self.size.height + self.restartButton.size.height)/2 + restartMargin);
        [self addChild:self.restartButton];
        
        SKLabelNode *restartLabel = [[SKLabelNode alloc] initWithFontNamed:[UIFont lr_letterBlockFont]];
        restartLabel.text = @"R";
        self.restartButton.titleLabel = restartLabel;
        
        //to do: move this to a specific update method
        [_wordsValue updateValue:[[[LRScoreManager shared] submittedWords] count] animated:YES durationPerNumber:.02];
        [_lettersValue updateValue:[[LRScoreManager shared] lettersCollected] animated:YES durationPerNumber:.02];
        [_scoreValue updateValue:[[LRScoreManager shared] score] animated:YES totalDuration:0.5];
    }
    
    return self;
}

+ (SKLabelNode *)_gameOverLabelNodeWithText:(NSString *)text
{
    SKLabelNode *labelNode = [[SKLabelNode alloc] initWithFontNamed:[UIFont lr_displayFontRegular]];
    labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    labelNode.fontColor = [UIColor textDarkBlue];
    labelNode.fontSize = kLRGameOverFontSize;
    labelNode.text = text;
    return labelNode;
}

- (NSString *)_scoreInfoTitleText
{
    NSArray *scoreInfoTexts = @[@"Sweet Run!", @"Excellente!", @"Nice Job!", @"Aces ten!"];
    return [scoreInfoTexts[arc4random()%[scoreInfoTexts count]] uppercaseString];
}

- (void)_close
{
    [self.presentationNode removeChildrenInArray:@[self, self.dropShadow]];
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_NEW_GAME object:nil];
}

@end

@implementation LRGameOverValueLabel
{
    SKLabelNode *_titleNode;
    LRValueLabelNode *_valueNode;
}
- (id)initWithTitle:(NSString *)title initialValue:(NSInteger)initialValue
{
    if (self = [super init])
    {
        NSString *fontName = [UIFont lr_displayFontRegular];
        CGFloat fontSize = kLRGameOverFontSize;
        
        if (title)
        {
            _titleNode = [[SKLabelNode alloc] initWithFontNamed:fontName];
            _titleNode.text = title;
            _titleNode.fontSize = fontSize;
            _titleNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            _titleNode.fontColor = [UIColor textDarkBlue];
            [self addChild:_titleNode];
        }

        _valueNode = [[LRValueLabelNode alloc] initWithFontNamed:fontName initialValue:initialValue];
        _valueNode.fontSize = fontSize;
        _valueNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _valueNode.fontColor = [UIColor textOrange];
        
        _valueNode.position = CGPointMake(_titleNode.position.x + _titleNode.frame.size.width, 0);
        
        [self addChild:_valueNode];
    }
    return self;
}

- (void)updateValue:(NSInteger)value animated:(BOOL)animated durationPerNumber:(CGFloat)duration
{
    if (_valueNode)
    {
        [_valueNode updateValue:value animated:animated durationPerNumber:duration];
    }
}

- (void)updateValue:(NSInteger)value animated:(BOOL)animated totalDuration:(CGFloat)totalDuration
{
    if (_valueNode)
    {
        [_valueNode updateValue:value animated:animated totalDuration:totalDuration];
    }
}

- (CGRect)frame
{
    CGPoint origin = (_titleNode) ? _titleNode.frame.origin : _valueNode.frame.origin;
    CGSize size = CGSizeMake(_titleNode.frame.size.width + _valueNode.frame.size.width, _valueNode.frame.size.height);
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

@end

@implementation LRCollectedWordColoredLabel
{
    NSMutableArray *_labels;
}
- (id)initWithArray:(NSArray *)array
{
    if (self = [super init])
    {
        _labels = [NSMutableArray new];
        for (NSDictionary *kv in array)
        {
            LRPaperColor paperColor = [[kv allValues][0] integerValue];
            NSString *text = [[kv allKeys] firstObject];
            SKLabelNode *label = [LRGameOverMenu _gameOverLabelNodeWithText:text];
            label.fontColor = [UIColor primaryColorForPaperColor:paperColor];
            label.fontSize = 24.0;
            [_labels addObject:label];
        }
        
        CGFloat xOffset = -2.0;
        CGPoint position = CGPointZero;
        for (SKLabelNode *label in _labels)
        {
            label.position = position;
            [self addChild:label];
            position = CGPointMake(position.x + label.frame.size.width + xOffset, position.y);
        }
    }
    return self;
}

- (CGRect)frame
{
    CGPoint origin = ([_labels count]) ? [_labels[0] frame].origin : CGPointZero;
    CGFloat height = ([_labels count]) ? [_labels[0] frame].size.height : 0;
    CGFloat width = [[_labels lastObject] frame].size.width + [[_labels lastObject] frame].origin.x - [[_labels firstObject] frame].origin.x;
    return CGRectMake(origin.x, origin.y, width, height);
}


@end

