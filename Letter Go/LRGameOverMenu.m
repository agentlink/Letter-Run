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

@interface LRGameOverMenu ()
@property (nonatomic, strong) LRShadowRoundedButton *restartButton;
@property (nonatomic, weak) SKNode *presentationNode;
@property (nonatomic, weak) SKSpriteNode *dropShadow;
@end

@implementation LRGameOverMenu

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
        NSMutableArray *scoreLabels = [NSMutableArray new];
        
        CGFloat labelLeftMargin = 8.0;
        LRValueLabelNode *levelValue = [[LRValueLabelNode alloc] initWithFontNamed:[UIFont lr_displayFontRegular]initialValue:[[LRProgressManager shared] level]];
        levelValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        levelValue.fontColor = [UIColor textDarkBlue];
        levelValue.fontSize = 24.0;
        levelValue.preValueString = @"Level: ";

        LRValueLabelNode *wordsValue = [[LRValueLabelNode alloc] initWithFontNamed:[UIFont lr_displayFontRegular]initialValue:0];
        wordsValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        wordsValue.fontColor = [UIColor textDarkBlue];
        wordsValue.fontSize = 24.0;
        wordsValue.preValueString = @"Words: ";


        LRValueLabelNode *letterValue = [[LRValueLabelNode alloc] initWithFontNamed:[UIFont lr_displayFontRegular] initialValue:0];
        letterValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        letterValue.fontColor = [UIColor textDarkBlue];
        letterValue.fontSize = 24.0;
        letterValue.preValueString = @"Letters: ";

        
        [scoreLabels addObjectsFromArray:@[levelValue, wordsValue, letterValue]];

        CGFloat topMargin = scoreInfoShadow.height;
        CGFloat betweenY = 5.0;
        CGFloat yVal = scoreInfoRect.size.height/2 - topMargin;
        for (LRValueLabelNode *label in scoreLabels)
        {
            yVal -= label.frame.size.height + betweenY;
            label.position = CGPointMake((-scoreInfoRect.size.width)/2 + labelLeftMargin, yVal);
            [scoreInfoRect addChild:label];
        }
        
        [wordsValue updateValue:[[[LRScoreManager shared] submittedWords] count] animated:YES];
        [letterValue updateValue:[[LRScoreManager shared] lettersCollected] animated:YES];
        
        
        //restart button
        
        CGFloat restartMargin = shadow.height + 13.0;
        self.restartButton = [[LRShadowRoundedButton alloc] initWithColor:[UIColor buttonLightBlue] size:CGSizeMake(50.0, 54.0) shadow:[LRShadow shadowWithHeight:5.0 color:[UIColor buttonDarkBlue] top:NO radius:5.0]];
        [self.restartButton setTouchUpInsideTarget:self action:@selector(_close)];
        self.restartButton.position = CGPointMake(0, (-self.size.height + self.restartButton.size.height)/2 + restartMargin);
        [self addChild:self.restartButton];
        
        SKLabelNode *restartLabel = [[SKLabelNode alloc] initWithFontNamed:[UIFont lr_letterBlockFont]];
        restartLabel.text = @"R";
        self.restartButton.titleLabel = restartLabel;
    }
    return self;
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
