//
//  LRDifficultyManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/15/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRObject.h"

@interface LRDifficultyManager : LRObject

typedef enum  {
    IncreaseStyle_None,
    IncreaseStyle_Linear,
    IncreaseStyle_Exponential
} IncreaseStyle;

+ (LRDifficultyManager*) shared;

- (void) increaseLevel;
- (void) resetLevel;

- (CGFloat) letterDropPeriod;

#pragma mark - Score Properties
//Determines whether the length of a word affects its score linearly or exponentially
@property (nonatomic) IncreaseStyle scoreIncreaseStyle;
//The value the score is multiplied by/to the power of
@property (nonatomic) CGFloat totalScoreFactor;
//The score per letter BEFORE the total score factor is applied
@property (nonatomic) CGFloat scorePerLetter;


#pragma mark - Level Up Properties
//Determines whether total score needed to move to the next level increases or not
@property (nonatomic) IncreaseStyle levelScoreIncreaseStyle;
/*
 The score needed to get to the next level.
 If the levelScoreIncreaseStyle is linear, then this is also the score needed to
 be reached to go to every level.
*/
@property (nonatomic) CGFloat initialNextLevelScore;
/*
 If the score needed to move on to the next level increases with each subsequent level,
 this is the factor by which that necessary score increases every time.
*/
@property (nonatomic) CGFloat levelScoreIncreaseFactor;


#pragma mark - Letter Drop Properties
//The time difference between letters being dropped in the first round
@property (nonatomic) CGFloat intialLetterDropPeriod;
//By how much the rate of letters dropping speeds up every time
@property (nonatomic) CGFloat letterDropPeriodDecreaseRate;
/*
 IncreaseStyle_Linear: Goes down by letterDropPeriodDecreaseRate each time, has a minumum value
 IncreaseStyle_Exponential: Divides itself be letterDropPeriodDecreaseRate
 */
@property (nonatomic) IncreaseStyle letterDropDecreaseStyle;
//Only set if IncreaseStyle_Linear
@property (nonatomic) CGFloat minimumDropPeriod;

#pragma mark - Health Bar Properties
//How many pixels the health bar moves per point scored
@property (nonatomic) CGFloat healthBarToScoreRatio;
@property (nonatomic) BOOL healthFallsOverTime;

#pragma mark - Letter Generation Properties
@property int maxNumber_consonants;
@property int maxNumber_vowels;

@end

