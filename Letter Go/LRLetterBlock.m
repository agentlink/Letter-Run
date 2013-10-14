//
//  LRLetterBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"
#import "LRConstants.h"
#import "LRCollisionManager.h"

#import "LRGameScene.h"
#import "LRGameStateManager.h"
#import "LRLetterSlot.h"

@interface LRLetterBlock ()
@end
@implementation LRLetterBlock

#pragma mark - Initializers/Set Up
+ (LRLetterBlock*) letterBlockWithLetter:(NSString*)letter;
{
    return [[LRLetterBlock alloc] initWithLetter:letter];
}

- (id) initWithLetter:(NSString *)letter
{
    if (self = [super initWithColor:[SKColor blackColor] size:CGSizeMake(LETTER_BLOCK_SIZE, LETTER_BLOCK_SIZE)]) {
        self.letter = letter;
        [self createObjectContent];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) createObjectContent
{
    SKLabelNode *letterLabel = [[SKLabelNode alloc] init];
    letterLabel.text = self.letter;
    letterLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - letterLabel.frame.size.height/2);
    [self addChild:letterLabel];
}



/*
#pragma mark - Touch Functions
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location))
        {
            self.playerMovedTouch = FALSE;
            if (self.vertMovementEnabled) {
                self.blockState = BlockState_PlayerIsHolding;
                self.originalPoint = self.position;
                self.position = location;
                [self removePhysics];
            }
            //If the block is in the letter section
            else if (self.blockInLetterSection) {
                [self releaseBlockForRearrangement];
            }
            self.zPosition += 5;
        }
    }
}

//Swipe function is done here by checking to see how far the player moved the block
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        //If the block is within the letter section
        if (self.blockInLetterSection ) {
            self.position = CGPointMake(location.x, self.position.y);
        }
        else if (!CGRectContainsPoint(self.frame, location))
        {
            if (self.vertMovementEnabled) {
                [self flingTowardsLocation:location];
            }
        }
    }
}

- (void) releaseBlockForRearrangement
{
    LRLetterSection *letterSection = [[(LRGameScene*)[self scene] gamePlayLayer] letterSection];
    LRLetterSlot *parentSlot = (LRLetterSlot*)[self parent];
    CGPoint newPos = [self convertPoint:self.position toNode:letterSection];
    [parentSlot setEmptyLetterBlock];
    self.position = newPos;
    [letterSection addChild:self];
    self.blockState = BlockState_Rearranging;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REARRANGE_START object:self userInfo:[NSDictionary dictionaryWithObject:self forKey:@"block"]];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        self.zPosition -= 5;
        if (self.blockState == BlockState_Rearranging) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REARRANGE_FINISH object:self userInfo:[NSDictionary dictionaryWithObject:self forKey:@"block"]];
            self.blockState = BlockState_InLetterSlot;
            //return;
        }
        //If the block is falling but wasn't flung
        if (self.blockState == BlockState_PlayerIsHolding && self.vertMovementEnabled) {
            [self setUpPhysics];
            return;
        }
        //If the block is in the letter slot
        CGPoint location = [touch locationInNode:[self parent]];
        //If the player didn't move the block
        if (CGRectContainsPoint(self.frame, location) && !self.vertMovementEnabled && !self.playerMovedTouch)
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
    self.blockState = BlockState_BlockFlung;
}*/

@end
