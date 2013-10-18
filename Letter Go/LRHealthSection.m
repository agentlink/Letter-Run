//
//  LRHealthSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRHealthSection.h"

@interface LRHealthSection ()
@property SKSpriteNode *healthBar;
@property NSTimeInterval initialTime;
@property BOOL gameOver;
@end

@implementation LRHealthSection

- (void) createSectionContent
{
    //The color will be replaced by a health bar sprite
    self.healthBar = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:self.size];
    [self addChild:self.healthBar];
    self.initialTime = -1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartHealthBar) name:GAME_STATE_NEW_GAME object:nil];
}

- (void) update:(NSTimeInterval)currentTime
{
    if (self.gameOver)
        return;
    else if (self.initialTime == -1) {
        self.initialTime = currentTime;
        return;
    }
    //This will be gotten from the difficulty manager
    float speedFactor = 10;
    self.healthBar.position = CGPointMake(self.healthBar.position.x - ((currentTime - self.initialTime) * speedFactor), self.healthBar.position.y);
    self.initialTime = currentTime;
    
    CGRect barFrame = self.healthBar.frame;
    barFrame.origin = [self.parent convertPoint:barFrame.origin fromNode:self.healthBar];

    // Why does this line cut it off half way through?
    // if (!(CGRectIntersectsRect(self.frame, barFrame)))
    
    if (barFrame.origin.x < self.frame.origin.x - (2 * barFrame.size.width))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_GAME_OVER object:nil];
        self.gameOver = TRUE;
    }
}

- (void) submitWord:(NSString*) word;
{
    float letterFactor = 15;
    float newXValue = self.healthBar.position.x + ([word length] * letterFactor);
    //The bar cannot move farther left than the left most edge
    newXValue *= (newXValue > 0) ? 0 : 1;
    self.healthBar.position = CGPointMake(newXValue, self.healthBar.position.y);
                       
}

- (void) restartHealthBar
{
    self.healthBar.position = CGPointMake(0, self.healthBar.position.y);
    self.initialTime = -1;
    self.gameOver = FALSE;
}
@end
