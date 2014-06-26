//
//  LRMath.m
//  Letter Go
//
//  Created by Gabe Nicholas on 6/26/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMath.h"

@implementation LRMath

double quadratic_equation_y (double a, CGPoint vertex, double x) {
    return a * pow((x - vertex.x), 2) + vertex.y;
}


@end
