//
//  LRMailman.h
//  Letter Go
//
//  Created by Gabe Nicholas on 5/11/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRManfordAIManager.h"

@interface LRMailman : SKSpriteNode <LRManfordMovementDelegate>
- (void)startRun;
- (void)stopRun;
@end
