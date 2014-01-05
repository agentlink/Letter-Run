//
//  LRDifficultyManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/15/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRObject.h"
#import "LRDifficultyConstants.h"

typedef enum  {
    IncreaseStyle_None,
    IncreaseStyle_Linear,
    IncreaseStyle_Exponential
} IncreaseStyle;

static const int kNumberOfSlots = 4;

@interface LRDifficultyManager : LRObject

+ (LRDifficultyManager*) shared;

- (int) loveLetterProbability;
- (CGFloat) letterDropPeriod;
- (CGFloat) healthBarDropTime;
- (CGFloat) parallaxSpeedFactor;

@property NSDictionary *difficultyDict;
@property int level;

#pragma mark - Score Properties
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
@property int numLettersPerDrop;
@property IncreaseStyle letterDropDecreaseStyle;


#pragma mark - Health Bar Properties
@property CGFloat healthPercentIncreasePer100Pts;
@property CGFloat initialHealthDropTime;
@property CGFloat healthSpeedIncreaseFactor;
@property CGFloat healthBarMinDropTime;
//Not saved
@property CGFloat healthInFallenEnvelopes;


#pragma mark - Mailman/Love Letter Properties
@property CGFloat mailmanHitDamage;
@property int loveLetterMultiplier;
@property int percentLoveLetters;
@property CGFloat flingLetterSpeed;

#pragma mark - Letter Generation Properties
@property int maxNumber_consonants;
@property int maxNumber_vowels;
@property int maxNumber_sameLetters;

#pragma mark - Parallax Properties
@property CGFloat baseParallaxPixelsPerSecond;
@property CGFloat scrollingSpeedIncrease;
@property NSArray *parallaxLayerSpeeds;

#pragma mark - Damage Functions
//Not saved to NSUserDefaults
@property BOOL mailmanReceivesDamage;
@property BOOL healthBarFalls;
@property BOOL mailmanScreenSide;
@property BOOL lettersFallVertically;
@end
