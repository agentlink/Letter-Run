//
//  LRGameScene.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGameScene.h"

@implementation LRGameScene

- (id) init
{
    //LRScenes are always initialized to the full size of the screen
    if (self = [super initWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)]) {
    }
    return self;
}

- (void) didMoveToView:(SKView *)view
{
    [self setScaleMode:SKSceneScaleModeAspectFit];
    self.backgroundLayer = [[LRBackgroundLayer alloc] init];
    [self addChild:self.backgroundLayer];
}

+ (LRGameScene*) scene
{
    return [[self alloc] init];
}

- (CGRect) window
{
    return self.frame;
}

@end
