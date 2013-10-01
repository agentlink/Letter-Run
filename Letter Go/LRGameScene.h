//
//  LRGameScene.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRBackgroundLayer.h"
#import "LRGamePlayLayer.h"

@interface LRGameScene : SKScene

@property LRBackgroundLayer *backgroundLayer;
@property LRGamePlayLayer *gamePlayLayer;

+ (LRGameScene*) scene;
- (CGRect) window;

@end
