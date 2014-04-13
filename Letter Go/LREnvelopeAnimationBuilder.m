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
static CGFloat const kSwapEnvelopeAnimationDuration = .1;

//#toy
//The scale an envelope grows/shrinks to during it's overshoot
static CGFloat const kBubbleToScale = 1.15;
//How much time the overshooting takes compared to the refractory
static CGFloat const kBubbleToScaleUndershootDuration = .25;
static CGFloat const kBubbleToScaleOvershootDurationRatio = .5;
//How m
@implementation LREnvelopeAnimationBuilder

#pragma mark - Public Functions

+ (SKAction *)changeEnvelopeCanDeleteState:(BOOL)canDelete
{
    CGFloat angle = (canDelete) ? .1 /*6 degrees in radians*/: 0;
    CGFloat alpha = (canDelete) ? .5 : 1.0;
    CGFloat duration = .2;

    SKAction *fade = [SKAction fadeAlphaTo:alpha duration:duration];
    SKAction *rotate = [SKAction rotateToAngle:angle duration:duration];
    SKAction *rotateAndFade = [SKAction group:@[fade, rotate]];
    
    if (!canDelete) {
        return rotateAndFade;
    }
    
    //If it's not being deleted, make it wiggle back and forth forever
    CGFloat wiggleDuration = .5;
    SKAction *rotateTo = [SKAction rotateToAngle:angle duration:wiggleDuration];
    rotateTo.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *rotateFrom = [SKAction rotateToAngle:-angle duration:wiggleDuration];
    rotateFrom.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *wiggleForever = [SKAction repeatActionForever:[SKAction sequence:@[rotateFrom, rotateTo]]];
    SKAction *rotateAndWiggle = [SKAction sequence:@[rotateAndFade, wiggleForever]];
    
    return rotateAndWiggle;
}

+ (SKAction *)changeEnvelopeToTouchedState:(BOOL)envelopeTouched
{
    CGFloat scale = (envelopeTouched) ? kBubbleToScale : 1/kBubbleToScale;
    CGFloat duration = .1;
    SKAction *scaleAction = [SKAction scaleTo:scale duration:duration];
    scaleAction.timingMode = SKActionTimingEaseInEaseOut;
    
    return scaleAction;
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

+ (SKAction *)swapEnvelopeFromPoint:(CGPoint)start toPoint:(CGPoint)destination
{
    CGFloat duration = kSwapEnvelopeAnimationDuration;
    SKAction *action = [SKAction moveTo:destination duration:duration];
    action.timingMode = SKActionTimingEaseInEaseOut;
    return action;
}

+ (SKAction *)bubbleByScale:(CGFloat)scale withDuration:(NSTimeInterval)duration
{
    NSAssert(kBubbleToScaleOvershootDurationRatio <= 1.0 &&
             kBubbleToScaleOvershootDurationRatio >= 0.0, @"Over shoot duration must be less than 1");

    CGFloat undershootScale = 1/kBubbleToScale;
    CGFloat undershootDuration = duration * kBubbleToScaleUndershootDuration;
    SKAction *undershootAnimation = [SKAction scaleBy:undershootScale duration:undershootDuration];
    undershootAnimation.timingMode = SKActionTimingEaseIn;
    
    CGFloat overshootDuration = duration * kBubbleToScaleOvershootDurationRatio;
    CGFloat overshootScale = scale *  pow(kBubbleToScale, 2);
    SKAction *overshotScaleAnimation = [SKAction scaleBy:overshootScale duration:overshootDuration];
    overshotScaleAnimation.timingMode = SKActionTimingEaseOut;

    CGFloat refractoryDuration = duration - overshootDuration;
    CGFloat refractoryScale = scale / kBubbleToScale;
    SKAction *refractoryScaleAnimation = [SKAction scaleBy:refractoryScale  duration:refractoryDuration];
    refractoryScaleAnimation.timingMode = SKActionTimingEaseIn;

    SKAction *bubble = [SKAction sequence: @[undershootAnimation, overshotScaleAnimation, refractoryScaleAnimation]];
    return bubble;
}

+ (SKAction *)unbubbleWithDuration:(NSTimeInterval)duration
{
    CGFloat overshootDuration = duration * (kBubbleToScaleOvershootDurationRatio + kBubbleToScaleUndershootDuration/2);
    CGFloat overshootScale = 1/kBubbleToScale;
    SKAction *overshotScaleAnimation = [SKAction scaleTo:overshootScale duration:overshootDuration];
    overshotScaleAnimation.timingMode = SKActionTimingEaseIn;
    
    CGFloat refractoryDuration = duration - overshootDuration;
    CGFloat refractoryScale = 1;
    SKAction *refractoryScaleAnimation = [SKAction scaleTo:refractoryScale  duration:refractoryDuration];
    refractoryScaleAnimation.timingMode = SKActionTimingEaseOut;

    SKAction *bubble = [SKAction sequence: @[overshotScaleAnimation, refractoryScaleAnimation]];
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
