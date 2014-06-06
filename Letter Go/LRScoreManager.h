//
//  LRScoreManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRGameStateDelegate.h"

extern NSUInteger const kLRScoreManagerScorePerLetter;

@protocol LRScoreManagerDelegate <NSObject>
@optional
- (void)changeScoreWithAnimation:(BOOL)animated;
- (void)changeDistance;
@end

@interface LRScoreManager : SKNode <LRGameStateDelegate>

/// An array of the words that have bee submitted this round in teh order they were submitted
@property (readonly) NSMutableArray *submittedWords;
/// The player's current score
@property (readonly) NSUInteger score;
/// The distance the player has run
@property (nonatomic, readonly) NSUInteger distance;
/// The number of yellow envelopes collected
@property (readonly) NSUInteger numYellowEnvelopes;
/// The number of blue envelopes collected
@property (readonly) NSUInteger numBlueEnvelopes;
/// The number of pink envelopes collected
@property (readonly) NSUInteger numPinkEnvelopes;

/// The score delegate that handles showing the user when the score has changed
@property (nonatomic, weak) id <LRScoreManagerDelegate> delegate;
///The shared instance of the score manager
+ (LRScoreManager *)shared;

/*!
 This functions submits a word for scoring/storing and returns the score as calculated by scoreForWordWithDict:(NSDictionary)dict
 @param wordDict: Has word stored in "word" key and love letter indices scored in "loveLetters" set
 @return The score for the word
 */
- (NSUInteger)submitWord:(NSDictionary *)wordDict;

/*! This function calculates the score for a word, including bonuses for length and love letters
 @param wordDict: Has word stored in "word" key and love letter indices scored in "loveLetters" set
 @return The score for the word
 */
+ (NSUInteger)scoreForWordWithDict:(NSDictionary *)wordDict;

/*! This function allows an object to add to the distance that the mailman has run. Should only ever be called by the mailman
 @param distance: The amount by which the distance should be increased
 */
- (void)increaseDistanceByValue:(NSUInteger)distance;


@end



