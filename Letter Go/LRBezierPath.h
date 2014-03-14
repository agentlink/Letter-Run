//
//  LRBezierPath.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRBezierPath : UIBezierPath

@property CGPoint start, c1, c2, end;
+ (LRBezierPath *)bezierPath;

@end
