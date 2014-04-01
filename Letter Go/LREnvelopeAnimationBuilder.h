//
//  LREnvelopeAnimationBuilder.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 2/1/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRConstants.h"

static NSString *kAddLetterAnimationName = @"addLetterAnimation";

@interface LREnvelopeAnimationBuilder : NSObject

+ (SKAction *)deletionAnimationWithDelayForIndex:(NSUInteger)index;
+ (SKAction *)submitWordActionWithLetterAtIndex:(NSUInteger)index;
+ (SKAction *)addLetterAnimation;

+ (SKAction *)rearrangementLetterShiftedSlotsFromPoint:(CGPoint)start toPoint:(CGPoint)destination;
+ (SKAction *)rearrangementFinishedAnimationFromPoint:(CGPoint)start toPoint:(CGPoint)destination;

+ (SKAction *)bubbleByScale:(CGFloat)overshootScale withDuration:(NSTimeInterval)duration;

+ (SKAction *)actionWithCompletionBlock:(SKAction *)action block:(void (^)(void))completion;

@end
