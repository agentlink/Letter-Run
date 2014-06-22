//
//  LRMissionManager.h
//  Letter Go
//
//  Created by Gabe Nicholas on 6/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRMission : NSObject
@property (nonatomic, readonly) NSArray *paperColors;
@property (nonatomic, readonly) CGFloat healthDropTime;
- (NSUInteger)numberOfEnvelopesForColor:(LRPaperColor)paperColor;
@end

@interface LRLevelManager : NSObject
- (LRMission *)missionForLevel:(NSUInteger)level;
@end

