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

//Determines whether the length of a word affects its score linearly or exponentially
@property (nonatomic) IncreaseStyle scoreIncreaseStyle;
//The value the score is multiplied by/to the power of
@property (nonatomic) float totalScoreFactor;
//The score per letter BEFORE the total score factor is applied
@property (nonatomic) float scorePerLetter;
//How many pixels the health bar moves per point scored
@property (nonatomic) float healthBarToScoreRatio;

//Determines whether total score needed to move to the next level increases or not
@property (nonatomic) IncreaseStyle levelScoreIncreaseStyle;
/*
 The score needed to get to the next level.
 If the levelScoreIncreaseStyle is linear, then this is also the score needed to
 be reached to go to every level.
*/
@property (nonatomic) float initialNextLevelScore;
/*
 If the score needed to move on to the next level increases with each subsequent level,
 this is the factor by which that necessary score increases every time.
*/
@property (nonatomic) float levelScoreIncreaseFactor;


@property (nonatomic) BOOL healthFallsOverTime;
@end
