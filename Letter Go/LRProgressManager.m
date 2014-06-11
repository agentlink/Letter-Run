//
//  LRProgressManager.m
//  Letter Go
//
//  Created by Gabe Nicholas on 4/26/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRProgressManager.h"
#import "LRLevelManager.h"
#import "LRScoreManager.h"

//#toy
static CGFloat const kLRProgressManagerInitialScoreToNextLevel = 200;
static CGFloat const kLRProgressManagerNextLevelIncreaseRatio = 1.2;

@interface LRProgressManager ()
@property (nonatomic, readwrite) NSUInteger level;
@property (nonatomic, strong) NSMutableDictionary *collectedEnvelopesForCurrentLevel;
@property (nonatomic, strong) LRLevelManager *levelManager;
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
   
    self.levelManager = [[LRLevelManager alloc] init];
    [self resetRoundProgress];

    return self;
}

#pragma mark - Public Functions

- (void)resetRoundProgress
{
    self.level = 1;
}

- (BOOL)didIncreaseLevel
{
    NSDictionary *levelUpDict = [self.levelManager envelopesRequiredToWinCurrentLevel];
    for (NSNumber *key in [levelUpDict allKeys])
    {
        LRPaperColor color = [key integerValue];
        NSUInteger collected = [[LRScoreManager shared] envelopesCollectedForColor:color];
        NSUInteger reqCollected = [levelUpDict[key] unsignedIntegerValue];
        if (collected < reqCollected)
            return NO;
    }
    self.level++;
    return YES;
}

- (NSUInteger)scoreLeftForPaperColor:(LRPaperColor)color
{
    NSDictionary *levelDict = [self.levelManager envelopesRequiredToWinCurrentLevel];
    NSInteger envelopesToContinue = [levelDict[@(color)] integerValue];
    NSInteger colorScore = envelopesToContinue - [[LRScoreManager shared] envelopesCollectedForColor:color];
    return MAX(0, colorScore);
}

#pragma mark - Private Functions

+ (NSUInteger)_scoreForLevel:(NSUInteger)level
{
    return kLRProgressManagerInitialScoreToNextLevel * pow(kLRProgressManagerNextLevelIncreaseRatio, level - 1);
}

@end
