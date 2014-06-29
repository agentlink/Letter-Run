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
@property (nonatomic, readonly) NSString *missionDescription;

///Returns how many envelopes of a given color are required to complete a mission
- (NSUInteger)objectiveEnvelopesForColor:(LRPaperColor)paperColor;
///Returns the probability of a given envelope color being generated
- (NSInteger)probabilityForEnvelopeColor:(LRPaperColor)paperColor;
@end

@interface LRLevelManager : NSObject
- (LRMission *)missionForLevel:(NSUInteger)level;
@end

