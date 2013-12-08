//
//  LRBezierPath.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRBezierPath.h"

@implementation LRBezierPath
@synthesize start, c1, c2, end;

- (void) moveToPoint:(CGPoint)point
{
    [super moveToPoint:point];
    self.start = point;
}

- (void) addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2
{
    //Bezier curve creation source: http://tinyurl.com/beziercurveref
    
    [super addCurveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    self.c1 = controlPoint1;
    self.c2 = controlPoint2;
    self.end = endPoint;
}

- (id) init
{
    if (self = [super init]) {
    }
    return self;
}

+ (LRBezierPath*) bezierPath
{
    return [[LRBezierPath alloc] init];
}

@end
