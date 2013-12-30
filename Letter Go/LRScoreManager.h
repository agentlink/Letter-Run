//
//  LRScoreManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRScoreManager : SKNode
+ (LRScoreManager*) shared;

/*!
 @param wordDict: has word stored in "word" key and love letter indices scored in "loveLetters" set
 @return the score for the word
 */
- (int) submitWord:(NSDictionary*)wordDict;
- (int) score;

+ (int) scoreForWordWithDict:(NSDictionary*)wordDict;

@property (readonly) NSMutableArray *submittedWords;
@property (readonly) int scoreToNextLevel;

@end
