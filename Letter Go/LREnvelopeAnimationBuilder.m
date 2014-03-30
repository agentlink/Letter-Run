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
static CGFloat const kRearrangementLetterShiftMaxDuration = .08;

//#toy
//The scale an envelope grows/shrinks to during it's overshoot
static CGFloat const kBubbleToScaleRatioChange = 1.15;
//How much time the overshooting takes compared to the refractory
static CGFloat const kBubbleToScaleUndershootDuration = .25;
static CGFloat const kBubbleToScaleOvershootDurationRatio = .5;
//How m
@implementation LREnvelopeAnimationBuilder

#pragma mark - Public Functions
+ (SKAction *)submitWordActionWithLetterAtIndex:(NSUInteger)index
{
    //#toy
    CGFloat shrinkTime = 0.2;
    CGFloat letterDelayTime = [self _delayForIndex:index withTotalDelayTime:kTotalDelayTimeSubmit leadingDirection:kRightDirection];
    SKAction *deleteLetter;
    
    SKAction *delay = [SKAction waitForDuration:letterDelayTime];
    SKAction *shrink = [SKAction scaleTo:0 duration:shrinkTime];
    shrink.timingMode = SKActionTimingEaseIn;
    
    deleteLetter = [SKAction sequence:@[delay, shrink]];
    return deleteLetter;
}

+ (SKAction *)deletionAnimationWithDelayForIndex:(NSUInteger)index;
{
    return [LREnvelopeAnimationBuilder _shiftLetterInDirection:kLeftDirection withDelayForIndex:index];
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
    CGFloat distance = ABS(start.x - destination.x);
    CGFloat duration = distance * kRearrangementLetterShiftMaxDuration / kDistanceBetweenSlots;
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

+ (SKAction *)_shiftLetterInDirection:(kLRDirection)direction
{
    CGFloat animationTime = .2;
    CGFloat shiftDistance = kDistanceBetweenSlots;
    shiftDistance *= (direction == kLeftDirection) ? -1 : 1;

    SKAction *shiftLetter = [SKAction moveByX:shiftDistance y:0 duration:animationTime];
    return shiftLetter;
}

+ (SKAction *)_shiftLetterInDirection:(kLRDirection)direction withDelayForIndex:(NSUInteger)index
{
    CGFloat delayTime = [self _delayForIndex:index  withTotalDelayTime:kTotalDelayTimeDelete leadingDirection:kLeftDirection];
    SKAction *shift = [self _shiftLetterInDirection:direction];
    //Get the pre and post delay times so that all the actions end at the same time
    SKAction *delayAction = [SKAction waitForDuration:delayTime];
    
    SKAction *shiftWithDelay = [SKAction sequence:@[delayAction, shift]];
    return shiftWithDelay;
}

+ (CGFloat) _delayForIndex:(NSUInteger)index withTotalDelayTime:(CGFloat)totalDelay leadingDirection:(kLRDirection)direction
{
    CGFloat directionVal = (direction == kRightDirection) ? (kWordMaximumLetterCount - index) : index + 1;
    CGFloat delay = totalDelay * directionVal/kWordMaximumLetterCount;
    return delay;
}
@end
