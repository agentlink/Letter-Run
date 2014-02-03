//
//  LREnvelopeAnimationBuilder.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 2/1/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LREnvelopeAnimationBuilder.h"

static CGFloat const kTotalDelayTime = 0.25;

@implementation LREnvelopeAnimationBuilder

+ (SKAction*) submitWordActionWithLetterAtIndex:(NSUInteger)index
{
    //#toy
    CGFloat shrinkTime = 0.2;
    CGFloat letterDelayTime = [self delayForIndex:index leadingDirection:kRightDirection];
    SKAction *deleteLetter;
    
    SKAction *delay = [SKAction waitForDuration:letterDelayTime];
    SKAction *shrink = [SKAction scaleTo:0 duration:shrinkTime];
    shrink.timingMode = SKActionTimingEaseIn;
    
    deleteLetter = [SKAction sequence:@[delay, shrink]];
    return deleteLetter;
}

+ (SKAction*) shiftLetterInDirection:(kLRDireciton)direction
{
    CGFloat animationTime = .2;
    CGFloat shiftDistance = kLetterBlockDimension + kSlotMarginWidth;
    shiftDistance *= (direction == kLeftDirection) ? -1 : 1;

    SKAction *shiftLetter = [SKAction moveByX:shiftDistance y:0 duration:animationTime];
    return shiftLetter;
}

+ (SKAction*) shiftLetterInDirection:(kLRDireciton)direction withDelayForIndex:(NSUInteger)index
{
    CGFloat delayTime = [self delayForIndex:index leadingDirection:kLeftDirection];
    CGFloat letterPostDelayTime = kTotalDelayTime - delayTime;

    SKAction *shift = [self shiftLetterInDirection:direction];
    //Get the pre and post delay times so that all the actions end at the same time
    SKAction *preDelayAction = [SKAction waitForDuration:delayTime];
    SKAction *postDelayAction = [SKAction waitForDuration:letterPostDelayTime];
    
    SKAction *shiftWithDelay = [SKAction sequence:@[preDelayAction, shift, postDelayAction]];
    return shiftWithDelay;
}

+ (SKAction*) actionWithCompletionBlock:(SKAction*)action block:(void (^)(void))completion
{
    SKAction *blockAction = [SKAction runBlock:completion];
    SKAction *newBlock = [SKAction sequence:@[action, blockAction]];
    return newBlock;
}

+ (CGFloat) delayForIndex:(NSUInteger)index leadingDirection:(kLRDireciton)direction
{
    CGFloat directionVal = (direction == kRightDirection) ? (kWordMaximumLetterCount - index) : index + 1;
    CGFloat delay = kTotalDelayTime * directionVal/kWordMaximumLetterCount;
    return delay;
}
@end
