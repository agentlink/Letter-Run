//
//  LREnvelopeAnimationBuilder.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 2/1/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRConstants.h"

@interface LREnvelopeAnimationBuilder : NSObject

#pragma Letter State Change
+ (SKAction *)changeEnvelopeCanDeleteState:(BOOL)canDelete;
+ (SKAction *)changeEnvelopeToTouchedState:(BOOL)envelopeTouched;

#pragma Letter Addition/Removal
+ (SKAction *)addLetterAnimation;

#pragma Rearrangement
+ (SKAction *)swapEnvelopeFromPoint:(CGPoint)start toPoint:(CGPoint)destination;
+ (SKAction *)rearrangementFinishedAnimationFromPoint:(CGPoint)start toPoint:(CGPoint)destination;
+ (SKAction *)shiftLetterInDirection:(LRDirection)direction withDelayForIndex:(NSUInteger)index;
+ (SKAction *)bubbleByScale:(CGFloat)overshootScale withDuration:(NSTimeInterval)duration;
+ (SKAction *)unbubbleWithDuration:(NSTimeInterval)duration;

#pragma Submission
+ (SKAction *)submitWordActionWithLetterAtIndex:(NSUInteger)index;

#pragma Helper
+ (SKAction *)actionWithCompletionBlock:(SKAction *)action block:(void (^)(void))completion;

@end
