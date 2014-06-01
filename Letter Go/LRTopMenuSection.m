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

@interface LRTopMenuSection ()
@property (nonatomic, strong) SKSpriteNode *missionControlSprite;
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
    SKTexture *missionControlTexture = [[LRSharedTextureCache shared] textureForName:@"topMenuSection-missionControl"];
    self.missionControlSprite = [SKSpriteNode spriteNodeWithTexture:missionControlTexture];
    self.missionControlSprite.xScale = .47;
    self.missionControlSprite.yScale = .47;
    self.missionControlSprite.anchorPoint = CGPointMake(1, 1);
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


//
//- (LRButton *)pauseButton
//{
//    if (!_pauseButton) {
//        _pauseButton = [[LRButton alloc] initWithImageNamed:@"pause-button" withDisabledOption:NO];
//        [_pauseButton setScale:.7];
//        [_pauseButton setTouchUpInsideTarget:self action:@selector(pauseButtonPressed)];
//        _pauseButton.position = CGPointMake(0 - SCREEN_WIDTH/2 + _pauseButton.size.width/2, SCREEN_HEIGHT/2 - _pauseButton.size.height/2);
//        _pauseButton.zPosition = zPos_PauseButton;
//    }
//    return _pauseButton;
//}

@end
