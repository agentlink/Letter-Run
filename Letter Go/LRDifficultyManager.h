//
//  LRDifficultyManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/15/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRObject.h"
#import "LRDifficultyConstants.h"

@interface LRDifficultyManager : LRObject

typedef enum  {
    IncreaseStyle_None,
    IncreaseStyle_Linear,
    IncreaseStyle_Exponential
} IncreaseStyle;

+ (LRDifficultyManager*) shared;

- (void) loadUserDefaults;
- (void) runInitialLoad;

- (int) loveLetterProbability;
- (CGFloat) letterDropPeriod;
- (CGFloat) healthBarDropTime;
- (CGFloat) parallaxSpeedFactor;

@property int level;

#pragma mark - Score Properties
@property IncreaseStyle scoreIncreaseStyle;
@property CGFloat scoreLengthFactor;
@property int scorePerLetter;


#pragma mark - Level Up Properties
@property IncreaseStyle levelScoreIncreaseStyle;
@property int initialNextLevelScore;
@property CGFloat levelScoreIncreaseFactor;


#pragma mark - Letter Drop Properties
@property CGFloat initialLetterDropPeriod;
@property CGFloat letterDropPeriodDecreaseRate;
@property CGFloat minimumDropPeriod;
@property CGFloat flingLetterSpeed;
@property int numLettersPerDrop;
@property IncreaseStyle letterDropDecreaseStyle;


#pragma mark - Health Bar Properties
@property CGFloat healthPercentIncreasePer100Pts;
@property CGFloat initialHealthDropTime;
@property CGFloat healthSpeedIncreaseFactor;
@property IncreaseStyle healthSpeedIncreaseStyle;
@property CGFloat healthBarMinDropTime;

#pragma mark - Mailman/Love Letter Properties
@property CGFloat mailmanHitDamage;
@property CGFloat loveLetterBonus;
@property int percentLoveLetters;

#pragma mark - Letter Generation Properties
@property int maxNumber_consonants;
@property int maxNumber_vowels;
@property int maxNumber_sameLetters;

#pragma mark - Background Layer Properties
@property CGFloat initialScrollingSpeed;
@property CGFloat scrollingSpeedIncrease;
@property NSArray *parallaxLayerSpeeds;
@property CGFloat parallaxSpeed_Sky,
                    parallaxSpeed_Mountain,
                    parallaxSpeed_Hills,
                    parallaxSpeed_Grass;

#pragma mark - Damage Functions
//Not saved to NSUserDefaults
@property BOOL mailmanReceivesDamage;
@property BOOL healthBarFalls;

@end
