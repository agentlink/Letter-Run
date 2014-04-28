//
//  LRProgressManager.h
//  Letter Go
//
//  Created by Gabe Nicholas on 4/26/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRProgressManager : NSObject
///The progress manager singleton
+ (LRProgressManager *)shared;
///The level the player is currently on
@property (nonatomic, readonly) NSUInteger level;

///Returns YES if the level is increased by the score. It also increases the score for the level
- (BOOL)increasedLevelForScore:(NSUInteger)score;
///Resets the level to one
- (void)resetRoundProgress;

@end
