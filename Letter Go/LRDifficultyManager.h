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
    ScoreStyle_Exponential = FALSE,
    ScoreStyle_Linear = TRUE
} ScoreStyle;

+ (LRDifficultyManager*) shared;

//Determines whether the length of a word affects its score linearly or exponentially
@property (nonatomic) ScoreStyle scoreStyle;
//The value the score is multiplied by/to the power of
@property (nonatomic) float totalScoreFactor;
//The score per letter BEFORE the total score factor is applied
@property (nonatomic) float scorePerLetter;
//How many pixels the health bar moves per point scored
@property (nonatomic) float healthBarToScoreRatio;

@end
