//
//  LRScoreManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRGameStateDelegate.h"

@interface LRScoreManager : SKNode <LRGameStateDelegate>

/// An array of the words that have bee submitted this round in teh order they were submitted
@property (readonly) NSMutableArray *submittedWords;
/// The score required for the palyer to reach the next level
@property (readonly) int scoreToNextLevel;
/// Returns the player's current score
@property (readonly) int score;

///The shared instance of the score manager
+ (LRScoreManager*) shared;

/*!
 This functions submits a word for scoring/storing and returns the score as calculated by scoreForWordWithDict:(NSDictionary)dict
 @param wordDict: Has word stored in "word" key and love letter indices scored in "loveLetters" set
 @return The score for the word
 */
- (int) submitWord:(NSDictionary*)wordDict;

/*! This function calculates the score for a word, including bonuses for length and love letters
 @param wordDict: Has word stored in "word" key and love letter indices scored in "loveLetters" set
 @return The score for the word
 */
+ (int) scoreForWordWithDict:(NSDictionary*)wordDict;

@end
