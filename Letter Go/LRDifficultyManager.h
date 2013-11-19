//
//  LRDifficultyManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/15/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRObject.h"
#import "LRDifficultyConstants.h"

#define VALUE_CHANGED_STRING                @"_Value_Changed"

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
- (NSArray*) parallaxLayerSpeeds;

#pragma mark - Score Properties
//Determines whether the length of a word affects its score linearly or exponentially
@property (nonatomic) IncreaseStyle scoreIncreaseStyle;
//The value the score is multiplied by/to the power of
@property (nonatomic) CGFloat scoreLengthFactor;
//The score per letter BEFORE the total score factor is applied
@property (nonatomic) int scorePerLetter;


#pragma mark - Level Up Properties
@property int level;
//Determines whether total score needed to move to the next level increases or not
@property (nonatomic) IncreaseStyle levelScoreIncreaseStyle;
/*
 The score needed to get to the next level.
 If the levelScoreIncreaseStyle is linear, then this is also the score needed to
 be reached to go to every level.
*/
@property (nonatomic) int initialNextLevelScore;
/*
 If the score needed to move on to the next level increases with each subsequent level,
 this is the factor by which that necessary score increases every time.
*/
@property (nonatomic) CGFloat levelScoreIncreaseFactor;


#pragma mark - Letter Drop Properties
@property (nonatomic) CGFloat initialLetterDropPeriod;
@property (nonatomic) CGFloat letterDropPeriodDecreaseRate;
@property (nonatomic) CGFloat minimumDropPeriod;
@property (nonatomic) CGFloat flingLetterSpeed;
@property (nonatomic) int numLettersPerDrop;
@property (nonatomic) IncreaseStyle letterDropDecreaseStyle;


#pragma mark - Health Bar Properties
//How many pixels the health bar moves per point scored
@property (nonatomic) CGFloat healthPercentIncreasePer100Pts;
@property (nonatomic) CGFloat initialHealthDropTime;
@property (nonatomic) CGFloat healthSpeedIncreaseFactor;
@property (nonatomic) IncreaseStyle healthSpeedIncreaseStyle;
@property (nonatomic) CGFloat healthBarMinDropTime;

#pragma mark - Letter Generation Properties
@property int maxNumber_consonants;
@property int maxNumber_vowels;
@property int maxNumber_sameLetters;

#pragma mark - Background Layer Properties
@property CGFloat initialScrollingSpeed;
@property CGFloat scrollingSpeedIncrease;
@property CGFloat parallaxSpeed_Sky, parallaxSpeed_Mountain, parallaxSpeed_Hills, parallaxSpeed_Grass;


#pragma mark - Mailman Properties
@property CGFloat mailmanHitDamage;

#pragma mark - Damage Functions
//Not saved to NSUserDefaults
@property BOOL mailmanReceivesDamage;
@property BOOL healthBarFalls;

#pragma mark - Love Letter Propertis
@property CGFloat loveLetterBonus;
@property int percentLoveLetters;
@end

