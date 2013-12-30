//
//  LRBezierBuilder.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRCurveBuilder.h"
#import "LRDifficultyManager.h"
#import "LRMailman.h"

@implementation LRCurveBuilder

#define BEZIER_STEPS            10

static const CGFloat kVerticalCurveDuration = 2.0;
static const CGFloat kHorizontalCurveDuration = 7.0;

typedef enum {
    kSwingLeft  = -1,
    kSwingRight = 1
} SwingDirection;

#pragma mark - Curve Building Functions

+ (LRBezierPath*) bezierWithStart:(CGPoint)start c1:(CGPoint)c1
                               c2:(CGPoint)c2 end:(CGPoint)end
{
    LRBezierPath *path = [LRBezierPath bezierPath];
    [path moveToPoint:start];
    [path addCurveToPoint:end controlPoint1:c1 controlPoint2:c2];
    
    return path;
}

+ (NSArray*) verticalFallingLetterActionsWithHeight:(CGFloat)height andSwingCount:(int)swingCount
{
    //Set initial direction of the swing
    SwingDirection currentSwingDirection = kSwingLeft;
    //Set how far out each envelope swings
    CGFloat swingWidth = 70;
    
    CGFloat swingDropHeight = 0 - height/swingCount;
    CGPoint nextPosition = CGPointMake(swingWidth * currentSwingDirection, swingDropHeight);
    
    CGFloat rotationPerSwing = 10;
    //TODO: Get this from difficulty manager
    
    NSMutableArray *curveArray = [NSMutableArray array];
    
    for (int i = 0; i < swingCount; i++)
    {
        CGPoint start = CGPointMake(0, 0);
        CGPoint c1 = CGPointMake(0, 0);
        CGPoint c2 = CGPointMake(0, nextPosition.y);
        
        LRBezierPath *letterPath = [LRCurveBuilder bezierWithStart:start c1:c1 c2:c2 end:nextPosition];
        
        //Set the last position to land at the original x point
        SKAction *followPath = [SKAction followPath:[letterPath CGPath] asOffset:YES orientToPath:NO duration:kVerticalCurveDuration];
        SKAction *rotate;
        SKActionTimingMode swingTimingMode = SKActionTimingEaseInEaseOut;
        
        //If it's the last swing, make it land in the center
        if (i == swingCount - 1) {
            swingTimingMode = SKActionTimingEaseIn;
            rotate = [SKAction rotateToAngle:0 duration:kVerticalCurveDuration];
        }
        else {
            rotate = [SKAction rotateToAngle:currentSwingDirection * (rotationPerSwing * M_PI)/180 duration:kVerticalCurveDuration];
        }

        rotate.timingMode = swingTimingMode;
        followPath.timingMode = swingTimingMode;
        [curveArray addObject:[SKAction group:@[followPath, rotate]]];
        
        //Switch the swing direction
        if (i == swingCount - 2) nextPosition.x /= 2;
        currentSwingDirection = -1 * currentSwingDirection;
        nextPosition.x *= -1;
    }
    
    return curveArray;
}

+ (NSArray*) horizontalLetterActionForDistance:(CGFloat)distance;
{
    if ([[LRDifficultyManager shared] mailmanScreenSide] == MailmanScreenLeft)
        distance *= -1;
    
    CGPoint start = CGPointMake(0, 0);
    CGPoint c1 = CGPointMake(0, 0);
    CGPoint c2 = CGPointMake(distance, -15);
    CGPoint end = CGPointMake(distance, 0);
    
    LRBezierPath *letterPath = [LRCurveBuilder bezierWithStart:start c1:c1 c2:c2 end:end];
    SKAction *followPath = [SKAction followPath:[letterPath CGPath] asOffset:YES orientToPath:NO duration:kHorizontalCurveDuration];
    //followPath.timingMode = SKActionTimingEaseIn;
    
    return @[followPath];
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
