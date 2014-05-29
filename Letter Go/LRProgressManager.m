//
//  LRProgressManager.m
//  Letter Go
//
//  Created by Gabe Nicholas on 4/26/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRProgressManager.h"

//#toy
static CGFloat const kLRProgressManagerInitialScoreToNextLevel = 200;
static CGFloat const kLRProgressManagerNextLevelIncreaseRatio = 1.2;

@interface LRProgressManager ()
@property (nonatomic, readwrite) NSUInteger level;
@end

@implementation LRProgressManager
static LRProgressManager *_shared = nil;

#pragma mark - Set Up

+ (LRProgressManager *)shared
{
    @synchronized (self)
    {
		if (!_shared) {
			_shared = [[LRProgressManager alloc] init];
		}
	}
	return _shared;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.level = 1;
    return self;
}

#pragma mark - Public Functions

- (void)resetRoundProgress
{
    self.level = 1;
}

- (BOOL)increasedLevelForScore:(NSUInteger)score;
{
    NSUInteger scoreToNextLevel = [LRProgressManager _scoreForLevel:self.level];
    BOOL increasedLevel = NO;
    NSUInteger newLevel = self.level;
    while (score >= scoreToNextLevel) {
        newLevel += 1;
        increasedLevel = YES;
        scoreToNextLevel = [LRProgressManager _scoreForLevel:newLevel];
    }
    self.level = newLevel;
    return increasedLevel;
}

#pragma mark - Private Functions

+ (NSUInteger)_scoreForLevel:(NSUInteger)level
{
    return kLRProgressManagerInitialScoreToNextLevel * pow(kLRProgressManagerNextLevelIncreaseRatio, level - 1);
}

@end
