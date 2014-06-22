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
@property NSDictionary *paperColorDict;
@end

@interface LRLevelManager ()
@property NSArray *missionPropertyList;
@end

@implementation LRMission

#pragma mark - Public Methods

- (id)init
{
    if (self = [super init])
    {
        self.paperColorDict = [NSDictionary new];
    }
    return self;
}

- (NSUInteger)numberOfEnvelopesForColor:(LRPaperColor)paperColor
{
    NSString *key = [LRLetterBlock stringValueForPaperColor:paperColor];
    return [self.paperColorDict[key] unsignedIntegerValue];
}

- (NSArray *)paperColors
{
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *key in [self.paperColorDict allKeys])
    {
        [array addObject:@([LRLetterBlock paperColorForString:key])];
    }
    return array;
}

+ (instancetype)missionFromDictionary:(NSDictionary *)dict
{
    LRMission *mission = [LRMission new];
    mission.paperColorDict = dict;
    return mission;
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

