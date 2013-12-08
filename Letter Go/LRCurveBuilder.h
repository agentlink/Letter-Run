//
//  LRBezierBuilder.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "LRBezierPath.h"
@interface LRCurveBuilder : NSObject

+ (LRBezierPath*) bezierWithStart:(CGPoint)start
                               c1:(CGPoint)c1
                               c2:(CGPoint)c2
                              end:(CGPoint)end;

+ (NSArray*) createFallingLetterActionsWithHeight:(CGFloat)height andSwingCount:(int)swingCount;
+ (double) lengthOfBezierCurve:(LRBezierPath*)path;

@end
