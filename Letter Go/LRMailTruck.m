//
//  LRMailTruck.m
//  Letter Go
//
//  Created by Gabe Nicholas on 6/7/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMailTruck.h"
#import "LRSharedTextureCache.h"

@implementation LRMailTruck

- (id)init
{
    if (self = [super initWithTexture:[[LRSharedTextureCache shared] textureWithName:@"mailTruck"]])
    {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.userInteractionEnabled = NO;

    //When the truck is selected, have it drive away and then start the game.
    CGFloat offscreenX = (SCREEN_WIDTH + self.size.width)/2;
    SKAction *driveAway = [SKAction moveTo:CGPointMake(offscreenX, self.position.y) duration:2];
    driveAway.timingMode = SKActionTimingEaseIn;
    [self runAction:driveAway completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_NEW_GAME object:nil];
    }];
}

@end
