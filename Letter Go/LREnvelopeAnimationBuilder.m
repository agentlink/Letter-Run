//
//  LREnvelopeAnimationBuilder.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 2/1/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LREnvelopeAnimationBuilder.h"
#import "LRLetterSection.h"

//#toy
static CGFloat const kTotalDelayTimeSubmit = 0.4;
static CGFloat const kTotalDelayTimeDelete = 0.27;

//The time that the animation would take to cross the whole screen
static CGFloat const kRearrangementFinishedMaxDuration = .5;
//The time that the animation takes to move one slot
static CGFloat const kRearrangementLetterShiftMaxDuration = .09;

//#toy
//The scale an envelope grows/shrinks to during it's overshoot
static CGFloat const kBubbleToScaleRatioChange = 1.15;
//How much time the overshooting takes compared to the refractory
static CGFloat const kBubbleToScaleUndershootDuration = .25;
static CGFloat const kBubbleToScaleOvershootDurationRatio = .5;
//How m
@implementation LREnvelopeAnimationBuilder

#pragma mark - Public Functions

+ (SKAction *)changeEnvelopeCanDeleteState:(BOOL)canDelete
{
    //TODO: write a degree to radian function
    CGFloat baseAngle = .087222222; //5 degrees in radians
    CGFloat duration = .2;
    CGFloat angle = (canDelete) ? baseAngle: -baseAngle;
    CGFloat alpha = (canDelete) ? .5 : 1.0;

    SKAction *fade = [SKAction fadeAlphaTo:alpha duration:duration];
    SKAction *rotate = [SKAction rotateByAngle:angle duration:duration];
    SKAction *rotateAndFade = [SKAction group:@[fade, rotate]];
    return rotateAndFade;
}
+ (SKAction *)submitWordActionWithLetterAtIndex:(NSUInteger)index
{
    //#toy
    CGFloat shrinkTime = 0.2;
    CGFloat letterDelayTime = [self _delayForIndex:index withTotalDelayTime:kTotalDelayTimeSubmit leadingDirection:kLRDirectionRight];
    SKAction *deleteLetter;
    
    SKAction *delay = [SKAction waitForDuration:letterDelayTime];
    SKAction *shrink = [SKAction scaleTo:0 duration:shrinkTime];
    shrink.timingMode = SKActionTimingEaseIn;
    
    deleteLetter = [SKAction sequence:@[delay, shrink]];
    return deleteLetter;
}

+ (SKAction *)addLetterAnimation;
{
    //#toy
    CGFloat overshootDuration = .35;
    CGFloat overshootHeight = 15;
    CGFloat overshootActionDistance = kCollectedEnvelopeSpriteDimension + overshootHeight;
    SKAction *overshootAction = [SKAction moveBy:CGVectorMake(0, overshootActionDistance) duration:overshootDuration];
    overshootAction.timingMode = SKActionTimingEaseInEaseOut;
    
    CGFloat retractionDuration = .15;
    SKAction *retractionAction = [SKAction moveBy:CGVectorMake(0, -overshootHeight) duration:retractionDuration];
    retractionAction.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *addLetter = [SKAction sequence:@[overshootAction, retractionAction]];
    return addLetter;
}

+ (SKAction *)deletionAnimationWithDelayForIndex:(NSUInteger)index;
{
    return [LREnvelopeAnimationBuilder shiftLetterInDirection:kLRDirectionLeft withDelayForIndex:index];
}

+ (SKAction *)actionWithCompletionBlock:(SKAction *)action block:(void (^)(void))completion
{
    SKAction *blockAction = [SKAction runBlock:completion];
    SKAction *newBlock = [SKAction sequence:@[action, blockAction]];
    return newBlock;
}

+ (SKAction *)rearrangementFinishedAnimationFromPoint:(CGPoint)start toPoint:(CGPoint)destination
{
    CGFloat distance = ABS(start.x - destination.x);
    CGFloat duration = (distance * kRearrangementFinishedMaxDuration) / SCREEN_WIDTH;
    SKAction *action = [SKAction moveTo:destination duration:duration];
    return action;
}

+ (SKAction *)rearrangementLetterShiftedSlotsFromPoint:(CGPoint)start toPoint:(CGPoint)destination
{
    CGFloat duration = kRearrangementLetterShiftMaxDuration;
    SKAction *action = [SKAction moveTo:destination duration:duration];
    action.timingMode = SKActionTimingEaseInEaseOut;
    return action;
}

+ (SKAction *)bubbleByScale:(CGFloat)scale withDuration:(NSTimeInterval)duration
{
    NSAssert(kBubbleToScaleOvershootDurationRatio <= 1.0 &&
             kBubbleToScaleOvershootDurationRatio >= 0.0, @"Over shoot duration must be less than 1");

    CGFloat undershootScale = 1/kBubbleToScaleRatioChange;
    CGFloat undershootDuration = duration * kBubbleToScaleUndershootDuration;
    SKAction *undershootAnimation = [SKAction scaleBy:undershootScale duration:undershootDuration];
    undershootAnimation.timingMode = SKActionTimingEaseIn;
    
    CGFloat overshootDuration = duration * kBubbleToScaleOvershootDurationRatio;
    CGFloat overshootScale = scale *  pow(kBubbleToScaleRatioChange, 2);
    SKAction *overshotScaleAnimation = [SKAction scaleBy:overshootScale duration:overshootDuration];
    overshotScaleAnimation.timingMode = SKActionTimingEaseOut;

    CGFloat refractoryDuration = duration - overshootDuration;
    CGFloat refractoryScale = scale / kBubbleToScaleRatioChange;
    SKAction *refractoryScaleAnimation = [SKAction scaleBy:refractoryScale  duration:refractoryDuration];
    refractoryScaleAnimation.timingMode = SKActionTimingEaseIn;

    SKAction *bubble = [SKAction sequence: @[undershootAnimation, overshotScaleAnimation, refractoryScaleAnimation]];
    return bubble;
}

#pragma mark - Private Functions

+ (SKAction *)shiftLetterInDirection:(LRDirection)direction
{
    CGFloat animationTime = .2;
    CGFloat shiftDistance = kDistanceBetweenSlots;
    shiftDistance *= (direction == kLRDirectionLeft) ? -1 : 1;

    SKAction *shiftLetter = [SKAction moveByX:shiftDistance y:0 duration:animationTime];
    return shiftLetter;
}

+ (SKAction *)shiftLetterInDirection:(LRDirection)direction withDelayForIndex:(NSUInteger)index
{
    CGFloat delayTime = [self _delayForIndex:index  withTotalDelayTime:kTotalDelayTimeDelete leadingDirection:kLRDirectionLeft];
    SKAction *shift = [self shiftLetterInDirection:direction];
    //Get the pre and post delay times so that all the actions end at the same time
    SKAction *delayAction = [SKAction waitForDuration:delayTime];
    
    SKAction *shiftWithDelay = [SKAction sequence:@[delayAction, shift]];
    return shiftWithDelay;
}

+ (CGFloat) _delayForIndex:(NSUInteger)index withTotalDelayTime:(CGFloat)totalDelay leadingDirection:(LRDirection)direction
{
    CGFloat directionVal = (direction == kLRDirectionRight) ? (kWordMaximumLetterCount - index) : index + 1;
    CGFloat delay = totalDelay * directionVal/kWordMaximumLetterCount;
    return delay;
}
@end
