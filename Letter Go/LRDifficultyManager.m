//
//  LRDifficultyManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/15/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDifficultyManager.h"
#import "LRParallaxManager.h"
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
        if (![[NSUserDefaults standardUserDefaults] objectForKey:DV_HEALTHBAR_MAX_SPEED]) {
            [self runInitialLoad];
        }
        else {
            [self resetDifficultyValues];
            [self loadUserDefaults];
        }
        [self loadNotifications];
        [self loadUnsavedValues];
    }
    return self;
}

- (void) runInitialLoad
{
    [self resetDifficultyValues];
    [self setUserDefaults];
}

- (void) loadUnsavedValues
{
    self.mailmanReceivesDamage = YES;
    self.healthBarFalls = YES;
}

- (void) resetDifficultyValues {
    //This will eventually be replaced by changing the corresponding NSUserDefaults to the initial value stored in DifficultyVariables.plist (once they're all added)

    self.level = 1;
    self.scoreLengthFactor = 1.2;
    self.scorePerLetter = 10;
    self.healthPercentIncreasePer100Pts = 15.0;
    self.scoreIncreaseStyle = IncreaseStyle_Exponential;
    
    //Add levelScoreIncreaseFactor value if style is not IncreaseStyle_None
    
    self.levelScoreIncreaseStyle = IncreaseStyle_Linear;
    self.levelScoreIncreaseFactor = 50;
    self.initialNextLevelScore = 150;
    
    self.initialHealthDropTime = 60;
    self.healthSpeedIncreaseFactor = .5;
    self.healthSpeedIncreaseStyle = IncreaseStyle_Linear;
    self.healthBarMinDropTime = 12;
    
    self.intialLetterDropPeriod = 2;
    self.letterDropPeriodDecreaseRate = 1.2;
    self.letterDropDecreaseStyle = IncreaseStyle_Exponential;
    self.minimumDropPeriod = .7;
    self.flingLetterSpeed = 300;
    
    self.maxNumber_consonants = 3;
    self.maxNumber_vowels = 3;
    self.maxNumber_sameLetters = 2;
    
    self.initialScrollingSpeed = 40;
    self.scrollingSpeedIncrease = 10;
    
    self.parallaxSpeed_Sky = .7;
    self.parallaxSpeed_Mountain = 1.8;
    self.parallaxSpeed_Hills = 2.8;
    self.parallaxSpeed_Grass = 3.7;
    
    self.mailmanHitDamage = 20;
    
    self.loveLetterBonus = 10;
}

- (void) setUserDefaults
{
    //Health
    [[NSUserDefaults standardUserDefaults] setFloat:self.initialHealthDropTime forKey:DV_HEALTHBAR_INITIAL_SPEED];
    [[NSUserDefaults standardUserDefaults] setFloat:self.healthSpeedIncreaseFactor forKey:DV_HEALTHBAR_INCREASE_FACTOR];
    [[NSUserDefaults standardUserDefaults] setFloat:self.healthBarMinDropTime forKey:DV_HEALTHBAR_MAX_SPEED];
    [[NSUserDefaults standardUserDefaults] setInteger:self.healthSpeedIncreaseStyle forKey:DV_HEALTHBAR_INCREASE_STYLE];
    [[NSUserDefaults standardUserDefaults] setFloat:self.healthPercentIncreasePer100Pts forKey:DV_HEALTHBAR_INCREASE_PER_WORD];
}

- (void) loadUserDefaults
{
    //Health
    self.initialHealthDropTime = [[NSUserDefaults standardUserDefaults] floatForKey:DV_HEALTHBAR_INITIAL_SPEED];
    self.healthSpeedIncreaseFactor = [[NSUserDefaults standardUserDefaults] floatForKey:DV_HEALTHBAR_INCREASE_FACTOR];
    self.healthBarMinDropTime = [[NSUserDefaults standardUserDefaults] floatForKey:DV_HEALTHBAR_MAX_SPEED];
    self.healthSpeedIncreaseStyle = [[NSUserDefaults standardUserDefaults] integerForKey:DV_HEALTHBAR_INCREASE_STYLE];
    self.healthPercentIncreasePer100Pts = [[NSUserDefaults standardUserDefaults] floatForKey:DV_HEALTHBAR_INCREASE_PER_WORD];
}

#pragma mark - Speed Factor Calculators

- (CGFloat) letterDropPeriod {
    float dropPeriod = self.intialLetterDropPeriod;
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
    return self.intialLetterDropPeriod;
}

- (CGFloat) parallaxSpeedFactor
{
    return self.initialScrollingSpeed + self.scrollingSpeedIncrease * self.level;
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

- (NSArray*) parallaxLayerSpeeds
{
    NSMutableArray *layerSpeeds = [NSMutableArray array];
    [layerSpeeds addObject:[NSNumber numberWithFloat:self.parallaxSpeed_Sky]];
    [layerSpeeds addObject:[NSNumber numberWithFloat:self.parallaxSpeed_Mountain]];
    [layerSpeeds addObject:[NSNumber numberWithFloat:self.parallaxSpeed_Hills]];
    [layerSpeeds addObject:[NSNumber numberWithFloat:self.parallaxSpeed_Grass]];
    
    return layerSpeeds;
}

@end
