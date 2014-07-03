//
//  LRGameOverMenu.m
//  Letter Go
//
//  Created by Gabe Nicholas on 6/24/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRGameOverMenu.h"
#import "LRSharedTextureCache.h"
#import "LRButton.h"
#import "LRPositionConstants.h"

@interface LRGameOverMenu ()
@property (nonatomic, weak) SKNode *parentNode;
@end
@implementation LRGameOverMenu
{
    SKSpriteNode *_backgroundBox;
}

+ (void)presentGameOverMenuFromNode:(SKNode *)parentNode
{
    LRGameOverMenu *menu = [[LRGameOverMenu alloc] init];
    menu.parentNode = parentNode;
    [parentNode addChild:menu];
    
}

- (id)init
{
    if (self = [super init])
    {
        self.zPosition = zPos_GameOver;
        SKTexture *boxTexture = [[LRSharedTextureCache shared] textureWithName:@"gameOverSection"];
        _backgroundBox = [[SKSpriteNode alloc] initWithTexture:boxTexture];

        //Game over label
        CGFloat topMargin = - 15;
        SKLabelNode *gameOverLabel = [LRGameOverMenu _gameOverLabel];
        gameOverLabel.position = CGPointMake(0, _backgroundBox.size.height/2 - gameOverLabel.frame.size.height + topMargin);
        [_backgroundBox addChild:gameOverLabel];

        //OK button
        CGFloat bottomMargin = 10;
        LRButton *okButton = [LRButton okButtonWithFontSize:20];
        [okButton setTouchUpInsideTarget:self action:@selector(_close)];
        okButton.anchorPoint = CGPointMake(.5, 0);
        okButton.size = CGSizeMake(70, 40);
        okButton.position = CGPointMake(0, -_backgroundBox.size.height/2 + bottomMargin);
        [_backgroundBox addChild:okButton];
        [self addChild:_backgroundBox];
    }
    return self;
}

#pragma mark - Private Methods

+ (SKLabelNode *)_gameOverLabel
{
    SKLabelNode *gameOverLabel = [[SKLabelNode alloc] init];
    LRFont *displayFont = [LRFont displayTextFontWithSize:100];
    gameOverLabel.text = @"Game Over";
    gameOverLabel.fontName = displayFont.familyName;
    gameOverLabel.fontSize = 40.0;
    gameOverLabel.fontColor = [UIColor gameOverLabelColor];
    return gameOverLabel;

}

- (void)_close
{
    [self.parentNode removeChildrenInArray:@[self]];
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_NEW_GAME object:nil];
}

@end
