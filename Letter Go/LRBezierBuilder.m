//
//  LRBezierBuilder.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRBezierBuilder.h"

@implementation LRBezierBuilder

#define BEZIER_STEPS            10


+ (LRBezierPath*) bezierWithStart:(CGPoint)start c1:(CGPoint)c1
                               c2:(CGPoint)c2 end:(CGPoint)end;
{
    LRBezierPath *path = [LRBezierPath bezierPath];
    [path moveToPoint:start];
    [path addCurveToPoint:end controlPoint1:c1 controlPoint2:c2];
    
    return path;
}

#pragma mark - Bezier Length Functions

/*  These functions are based off of Javascript found on bit.ly/9xZtnW  */

+ (double) lengthOfBezierCurve:(LRBezierPath *)path
{
    CGPoint start = path.start;
    CGPoint c1 = path.c1;
    CGPoint c2 = path.c2;
    CGPoint end = path.end;
    
    double t;
    int steps = BEZIER_STEPS;
    double length = 0.0;
    
    CGPoint dot;
    CGPoint previousDot;
    
    for (int i = 0; i < BEZIER_STEPS; i++)
    {
        t = (double)i/ (double)steps;
        dot.x = bezier_point(t, start.x, c1.x, c2.x, end.x);
        dot.y = bezier_point(t, start.y, c1.y, c2.y, end.y);
        
        if (i > 0) {
            double x_diff = dot.x - previousDot.x;
            double y_diff = dot.y - previousDot.y;
            length += sqrt(x_diff * x_diff + y_diff * y_diff);
        }
        previousDot = dot;
    }
    return length;
}

static inline double bezier_point (double t, double start, double c1, double c2, double end)
{
    return start * (1.0 - t) * (1.0 - t)  * (1.0 - t)
    + 3.0 *  c1 * (1.0 - t) * (1.0 - t)  * t
    + 3.0 *  c2 * (1.0 - t) * t * t
    + end * t * t * t;
}

@end
