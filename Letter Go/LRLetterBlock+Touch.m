//
//  LRLetterBlock+Touch.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock+Touch.h"
#import "LRNameConstants.h"

@implementation LRLetterBlock (Touch)

#pragma mark - Touch Functions
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location))
        {
            if (self.movementEnabled) {
                self.blockFlung = FALSE;
                self.originalPoint = self.position;
                self.position = location;
                [self removePhysics];
            }
        }
    }
}

//Swipe function is done here by checking to see how far the player moved the block
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (!CGRectContainsPoint(self.frame, location))
        {
            if (self.movementEnabled) {
                [self flingTowardsLocation:location];
            }
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        //If the block is falling but wasn't flung
        if (!self.blockFlung && self.movementEnabled) {
            [self setUpPhysics];
            return;
        }
        //If the block is in the letter slot
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location) && !self.movementEnabled)
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self forKey:KEY_GET_LETTER_BLOCK];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DELETE_LETTER object:self userInfo:dict];
        }
    }
}

- (void) flingTowardsLocation:(CGPoint)location
{
    [self setUpSwipedPhysics];
    float xDiff = location.x - self.originalPoint.x;
    float yDiff = location.y - self.originalPoint.y;
    float xToYRatio = xDiff / (ABS(xDiff) + ABS(yDiff));
    float yToXRatio = yDiff / (ABS(xDiff) + ABS(yDiff));
    
    float speedFactor = 500;
    self.physicsBody.velocity = CGVectorMake(speedFactor * xToYRatio, speedFactor * yToXRatio);
    self.blockFlung = TRUE;
}
@end
