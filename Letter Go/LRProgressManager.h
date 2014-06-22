//
//  LRProgressManager.h
//  Letter Go
//
//  Created by Gabe Nicholas on 4/26/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRLevelManager.h"

@interface LRProgressManager : NSObject
///The progress manager singleton
+ (LRProgressManager *)shared;
///The level the player is currently on
@property (nonatomic, readonly) NSUInteger level;

///Returns YES if the player has collected all required envelopes to beat the level
- (BOOL)didIncreaseLevel;
///Resets the level to one
- (void)resetRoundProgress;
//Returns the required score for a given envelope
- (NSUInteger)scoreLeftForPaperColor:(LRPaperColor)color;
- (LRMission *)currentMission;
@end
