//
//  LRDifficultyManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/15/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDifficultyManager.h"
#import "LRDifficultyManager+Notifications.h"

@interface LRDifficultyManager ()
@end

@implementation LRDifficultyManager

# pragma mark - Init Functions
static LRDifficultyManager *_shared = nil;
+ (LRDifficultyManager*) shared
{
    @synchronized (self)
    {
		if (!_shared) {
			_shared = [[LRDifficultyManager alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init]) {
        [self loadDifficultyInfo];

        //Check to see if NSUserDefaults have been loaded
        if (![[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_LOADED]) {
            [self writeUserDefaults];
        }
        [self loadNotifications];
        [self loadUserDefaults];
        [self loadUnsavedValues];
    }
    return self;
}

- (void) loadDifficultyInfo
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DifficultyVariables" ofType:@"plist"];
    self.difficultyDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

#pragma mark - Speed Factor Calculators

- (CGFloat) letterDropPeriod {
    float dropPeriod = self.initialLetterDropPeriod;
    for (int i = 1; i < self.level; i++) {
        if (self.letterDropDecreaseStyle == IncreaseStyle_Linear) {
            dropPeriod-= self.letterDropPeriodDecreaseRate;
        }
        else if (self.letterDropPeriodDecreaseRate == IncreaseStyle_Exponential) {
            dropPeriod/= self.letterDropPeriodDecreaseRate;
        }
    }
    if (self.minimumDropPeriod > dropPeriod)
        return self.minimumDropPeriod;
    return self.initialLetterDropPeriod;
}

- (CGFloat) parallaxSpeedFactor
{
    return self.baseParallaxPixelsPerSecond + self.scrollingSpeedIncrease * self.level;
}

- (CGFloat) healthBarDropTime
{
    //Unit: percent falling per second
    CGFloat healthSpeed = self.initialHealthDropTime;
    if (self.healthSpeedIncreaseStyle == IncreaseStyle_Linear) {
        for (int i = 1; i < self.level; i++) {
                healthSpeed -= self.healthSpeedIncreaseFactor;
            }
    }
    else if (self.healthSpeedIncreaseStyle == IncreaseStyle_Exponential) {
        for (int i = 1; i < self.level; i++) {
            healthSpeed /= self.healthSpeedIncreaseFactor;
        }
    }
    
    if (healthSpeed < self.healthBarMinDropTime)
        return self.healthBarMinDropTime;
    return healthSpeed;
}

- (int) loveLetterProbability
{
    return self.percentLoveLetters;
}

@end
