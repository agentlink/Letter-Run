//
//  LRManfordAIManager.h
//  Letter Go
//
//  Created by Gabe Nicholas on 5/10/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRManfordAIManager : SKNode

///The shared Manford AI Manager
+ (LRManfordAIManager *)shared;
/*!
 @description Called by the moving envelope to get the its envelope ID
 @param row The row the envelope will be generated in
 @return The value of the next envelopeID
 */
- (NSUInteger)nextEnvelopeIDForRow:(NSUInteger)row;


@end
