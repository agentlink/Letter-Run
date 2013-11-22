//
//  LRDifficultyConstants.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/9/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//


#define NOTIFICATION_LOAD_DVS_FROM_DEFAULTS         @"Load difficulty values form NSUserDefaults"
#define USER_DEFAULT_KEY                            @"userDefaultTag"

//Styles
#define STYLE_NONE                                  @"None"
#define STYLE_LINEAR                                @"Linear"
#define STYLE_EXPONENTIAL                           @"Exponential"

//Categories
#define CATEGORY_SCORE                              @"Score"
#define CATEGORY_HEALTH                             @"Health Bar"
#define CATEGORY_DROP                               @"Letter Drop"
#define CATEGORY_MAILMAN                            @"Mailman"
#define CATEGORY_GENERATOIN                         @"Letter Generation"
#define SELECTOR_ID_STRING                          @"_STYLE"





/* NOTIFICATIONS */

//Health
#define DV_HEALTHBAR_INITIAL_SPEED                  @"DV_HEALTHBAR_INITIAL_SPEED"
#define DV_HEALTHBAR_INCREASE_FACTOR                @"DV_HEALTHBAR_INCREASE_FACTOR"
#define DV_HEALTHBAR_MAX_SPEED                      @"DV_HEALTHBAR_MAX_SPEED"
#define DV_HEALTHBAR_INCREASE_STYLE                 @"DV_HEALTHBAR_INCREASE_STYLE"
#define DV_HEALTHBAR_INCREASE_PER_WORD              @"DV_HEALTHBAR_INCREASE_PER_WORD"

//Score
#define DV_SCORE_PER_LETTER                         @"DV_SCORE_PER_LETTER"
#define DV_SCORE_WORD_LENGTH_FACTOR                 @"DV_SCORE_WORD_LENGTH_FACTOR"
#define DV_SCORE_INITIAL_LEVEL_PROGRESSION          @"DV_SCORE_INITIAL_LEVEL_PROGRESSION"
#define DV_SCORE_LEVEL_PROGRESS_INCREASE_FACTOR     @"DV_SCORE_LEVEL_PROGRESS_INCREASE_FACTOR"
#define DV_SCORE_LENGTH_INCREASE_STYLE              @"DV_SCORE_LENGTH_INCREASE_STYLE"
#define DV_SCORE_LEVEL_PROGRESS_INCREASE_STYLE      @"DV_SCORE_LEVEL_PROGRESS_INCREASE_STYLE"

//Letter Drop
#define DV_DROP_MINIMUM_PERIOD                      @"DV_DROP_MINIMUM_PERIOD"
#define DV_DROP_PERIOD_DECREASE_FACTOR              @"DV_DROP_PERIOD_DECREASE_FACTOR"
#define DV_DROP_INITIAL_PERIOD                      @"DV_DROP_INITIAL_PERIOD"
#define DV_DROP_DECREASE_STYLE                      @"DV_DROP_DECREASE_STYLE"
#define DV_DROP_NUM_LETTERS                         @"DV_DROP_NUM_LETTERS"

//Mailman
#define DV_MAILMAN_LETTER_DAMAGE                    @"DV_MAILMAN_LETTER_DAMAGE"
#define DV_MAILMAN_LOVE_BONUS                       @"DV_MAILMAN_LOVE_BONUS"
#define DV_MAILMAN_LOVE_PERCENT                     @"DV_MAILMAN_LOVE_PERCENT"

//Letter Generation
#define DV_GENERATION_MAX_CONSONANTS                @"DV_GENERATION_MAX_CONSONANTS"
#define DV_GENERATION_MAX_VOWELS                    @"DV_GENERATION_MAX_VOWELS"
#define DV_GENERATION_MAX_LETTERS                   @"DV_GENERATION_MAX_LETTERS"

//Parallax
#define DV_PARALLAX_SPEED_ARRAY                     @"DV_PARALLAX_SPEED_ARRAY"

