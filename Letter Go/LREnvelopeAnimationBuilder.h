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

+ (SKAction*) shiftLetterInDirection:(kLRDireciton)direction;
+ (SKAction*) shiftLetterInDirection:(kLRDireciton)direction withDelayForIndex:(NSUInteger)index;

+ (SKAction*) submitWordActionWithLetterAtIndex:(NSUInteger)index;
+ (SKAction*) actionWithCompletionBlock:(SKAction*)action block:(void (^)(void))completion;

@end
