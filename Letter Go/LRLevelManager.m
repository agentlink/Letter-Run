//
//  LRMissionManager.m
//  Letter Go
//
//  Created by Gabe Nicholas on 6/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRLevelManager.h"
#import "LRLetterBlock.h"

@interface LRMission ()
+ (instancetype)missionFromDictionary:(NSDictionary *)dict;
@property (nonatomic, readwrite) NSDictionary *levelDict;
@property (nonatomic, readwrite) NSDictionary *objectivePaperColorDict;
@property (nonatomic, readwrite) NSString *missionDescription;
@end

@interface LRLevelManager ()
@property NSArray *missionPropertyList;
@end

@implementation LRMission

#pragma mark - Public Methods

+ (instancetype)missionFromDictionary:(NSDictionary *)dict
{
    LRMission *mission = [LRMission new];
    mission.levelDict = dict;
    return mission;
}

- (NSUInteger)objectiveEnvelopesForColor:(LRPaperColor)paperColor
{
    NSString *key = [LRLetterBlock stringValueForPaperColor:paperColor];
    return [self.objectivePaperColorDict[key] unsignedIntegerValue];
}

- (NSInteger)probabilityForEnvelopeColor:(LRPaperColor)paperColor
{
    NSDictionary *probabilityDict = self.levelDict[@"generation probabilities"];
    NSString *key = [LRLetterBlock stringValueForPaperColor:paperColor];
    if (!probabilityDict[key]) {
        return 0;
    }
    return [probabilityDict[key] integerValue];
}


- (NSArray *)paperColors
{
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *key in [self.objectivePaperColorDict allKeys])
    {
        [array addObject:@([LRLetterBlock paperColorForString:key])];
    }
    return array;
}

- (CGFloat)healthDropTime
{
    return [self.levelDict[@"health bar time"] floatValue];
}

#pragma mark - Private Methods

- (void)setLevelDict:(NSDictionary *)levelDict
{
    _levelDict = levelDict;
    self.objectivePaperColorDict = levelDict[@"objective"][@"paper colors"];
    self.missionDescription = levelDict[@"description"];
}
@end



@implementation LRLevelManager

- (id)init
{
    if (self = [super init])
    {
        //set up the plist
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Missions" ofType:@"plist"];
        NSArray *plist = [NSArray arrayWithContentsOfFile:path];
        self.missionPropertyList = plist;
    }
    return self;
}

- (LRMission *)missionForLevel:(NSUInteger)level
{
    //If there is not a mission for a given level, start the missions over
    if (level == 0)
    {
        NSLog(@"Warning: no mission for level 0");
    }
    NSUInteger modLevel = MAX(level%[self.missionPropertyList count], 1);
    NSDictionary *levelDict = self.missionPropertyList[modLevel];
    LRMission *mission = [LRMission missionFromDictionary:levelDict];
    return mission;
}

@end

