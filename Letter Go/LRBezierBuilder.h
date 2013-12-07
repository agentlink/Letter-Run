//
//  LRBezierBuilder.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRBezierPath.h"
@interface LRBezierBuilder : NSObject

+ (LRBezierPath*) bezierWithStart:(CGPoint)start
                               c1:(CGPoint)c1
                               c2:(CGPoint)c2
                              end:(CGPoint)end;

+ (double) lengthOfBezierCurve:(LRBezierPath*)path;

@end
