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
@property BOOL playerMovedTouch;
@end
@implementation LRLetterBlock

#pragma mark - Initializers/Set Up
+ (LRLetterBlock*) letterBlockWithSize:(CGSize)size andLetter:(NSString*)letter
{
    return [[LRLetterBlock alloc] initWithSize:size andLetter:letter];
}

- (id) initWithSize:(CGSize)size andLetter:(NSString *)letter;
{
    if (self = [super initWithColor:[SKColor blackColor] size:size]) {
        self.name = NAME_LETTER_BLOCK;
        self.letter = letter;
        self.vertMovementEnabled = YES;
        [self createObjectContent];
        [self setUpPhysics];
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

#pragma mark - Physics Functions
- (void) setUpPhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.affectedByGravity = YES;
    self.physicsBody.dynamic = YES;
    [[LRCollisionManager shared] setBitMasksForSprite:self];
    [[LRCollisionManager shared] addCollisionDetectionOfSpriteNamed:NAME_BOTTOM_EDGE toSprite:self];
}

- (void) setUpSwipedPhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.dynamic = YES;
    [[LRCollisionManager shared] setBitMasksForSprite:self];
    //Make it bounce off the bottom if the section is full
    if ([[LRGameStateManager shared] isLetterSectionFull])
        [[LRCollisionManager shared] addCollisionDetectionOfSpriteNamed:NAME_BOTTOM_EDGE toSprite:self];
    
}

- (void) removePhysics
{
    self.physicsBody = nil;
}

# pragma mark - Game Loop Checks
- (void) update:(NSTimeInterval)currentTime
{
    CGRect sceneRect = [(LRGameScene*)self.scene window];
    sceneRect.origin = [self convertPoint:sceneRect.origin fromNode:self.scene];
    CGRect letterFrame = self.frame;
    letterFrame.origin = [self convertPoint:self.frame.origin fromNode:self.parent];
    
    //If the box is within the letter box section
    if (CGRectContainsRect([(LRGameScene*)[self scene] gamePlayLayer].letterSection.frame, self.frame))
    {
        //Post the notification
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:self.letter forKey:KEY_GET_LETTER];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADDED_LETTER object:self userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DROP_LETTER object:self];
        [self removeFromParent];
    }
    //If the box is outside the screen and has been flung
    else if (!CGRectIntersectsRect(sceneRect, letterFrame)  && self.blockState == BlockState_BlockFlung) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DROP_LETTER object:self];
        [self removeFromParent];
    }
}

- (BOOL) isLetterBlockEmpty
{
    return ![[self letter] length];
}

- (BOOL) isLetterBlockPlaceHolder
{
    return ([self.letter isEqualToString:@" "]);
}

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
        if (self.blockInLetterSection && self.blockState != BlockState_Rearranging) {
            LRLetterSection *letterSection = [[(LRGameScene*)[self scene] gamePlayLayer] letterSection];
            LRLetterSlot *parentSlot = (LRLetterSlot*)[self parent];
            CGPoint newPos = [self convertPoint:self.position toNode:letterSection];
            [parentSlot setEmptyLetterBlock];
            self.position = newPos;
            [letterSection addChild:self];
            self.blockState = BlockState_Rearranging;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REARRANGE_START object:self userInfo:[NSDictionary dictionaryWithObject:self forKey:@"block"]];

        }
        if (self.blockInLetterSection ) {
            self.position = CGPointMake(location.x, self.position.y);
        }
        //If the block is outside the letter section
            //Has the player moved their touch outside the block?
        else if (!CGRectContainsPoint(self.frame, location))
        {
            self.playerMovedTouch = TRUE;
            if (self.vertMovementEnabled) {
                [self flingTowardsLocation:location];
            }
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        self.zPosition -= 5;
        if (self.blockState == BlockState_Rearranging) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REARRANGE_FINISH object:self userInfo:[NSDictionary dictionaryWithObject:self forKey:@"block"]];
            self.blockState = BlockState_InLetterSlot;
            return;
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
}

- (void) moveToNearestEmptySlot
{
    LRLetterSection *letterSection = [[(LRGameScene*)[self scene] gamePlayLayer] letterSection];
    [letterSection moveBlockToClosestEmptySlot:self];
}
@end
