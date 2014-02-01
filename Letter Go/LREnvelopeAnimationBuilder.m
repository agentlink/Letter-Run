//
//  LREnvelopeAnimationBuilder.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 2/1/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LREnvelopeAnimationBuilder.h"
#import "LRConstants.h"

@implementation LREnvelopeAnimationBuilder

+ (SKAction*) submitWordActionWithLetterAtIndex:(NSUInteger)index
{
    //#toy
    CGFloat shrinkTime = 0.2;
    CGFloat totalDelayTime = 0.3;
    CGFloat letterDelayTime = totalDelayTime * (kWordMaximumLetterCount - index)/kWordMaximumLetterCount;
    SKAction *deleteLetter;
    
    SKAction *delay = [SKAction waitForDuration:letterDelayTime];
    SKAction *shrink = [SKAction scaleTo:0 duration:shrinkTime];
    shrink.timingMode = SKActionTimingEaseIn;
    
    deleteLetter = [SKAction sequence:@[delay, shrink]];
    return deleteLetter;
}

+ (SKAction*) actionWithCompletionBlock:(SKAction*)action block:(void (^)(void))completion
{
    //TODO: test this function
    SKAction *blockAction = [SKAction runBlock:completion];
    SKAction *newBlock = [SKAction sequence:@[action, blockAction]];
    
    return newBlock;
}
@end
