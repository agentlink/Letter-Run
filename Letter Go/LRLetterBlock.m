//
//  LRLetterBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"
#import "LRNameConstants.h"
#import "LRCollisionManager.h"
#import "LRLetterBlock+Touch.h"

#import "LRGameScene.h"

@interface LRLetterBlock ()
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
        self.movementEnabled = YES;
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
        [userInfo setValue:self.letter forKey:NOTIFICATION_ADDED_LETTER];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADDED_LETTER object:self userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DROP_LETTER object:self];
        [self removeFromParent];
    }
    //If the box is outside the screen and has been flung
    else if (!CGRectIntersectsRect(sceneRect, letterFrame)  && self.blockFlung) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DROP_LETTER object:self];
        [self removeFromParent];
    }
}

- (BOOL) isLetterBlockEmpty
{
    return ![[self letter] length];
}

@end
