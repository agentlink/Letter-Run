//
//  LREnvelopeAnimationBuilder.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 2/1/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LREnvelopeAnimationBuilder : NSObject

+ (SKAction*) submitWordActionWithLetterAtIndex:(NSUInteger)index;
+ (SKAction*) actionWithCompletionBlock:(SKAction*)action block:(void (^)(void))completion;

@end
