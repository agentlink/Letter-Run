//
//  LRMissionManager.h
//  Letter Go
//
//  Created by Gabe Nicholas on 6/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, LRMissionType) {
    LRMissionTypePaperColor = 0x1 << 1,
    LRMisisonTypeWordLength = 0x1 << 2,
};

@interface LRMission : NSObject

@property (nonatomic, readonly) LRMissionType missionType;
@property (nonatomic, readonly) CGFloat healthDropTime;
@property (nonatomic, readonly) NSString *missionDescription;

///Returns how many envelopes of a given color are required to complete a mission
- (NSUInteger)objectiveEnvelopesForColor:(LRPaperColor)paperColor;
///Returns the number of words the player is required to get to complete a mission
- (NSUInteger)objectiveWordsForWordLength:(NSUInteger)length;
///Returns the probability of a given envelope color being generated
- (NSInteger)probabilityForEnvelopeColor:(LRPaperColor)paperColor;
@end

@interface LRLevelManager : NSObject
- (LRMission *)missionForLevel:(NSUInteger)level;
@end

