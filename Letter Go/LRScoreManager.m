//
//  LRScoreManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRScoreManager.h"

#import "LRGameScene.h"
#import "LRDifficultyManager.h"

@interface LRScoreManager ()
@property (nonatomic) int score;
@property (readwrite) int scoreToNextLevel;
@property int lastScoreToNextLevel;

@end

@implementation LRScoreManager
@synthesize submittedWords, scoreToNextLevel;
static LRScoreManager *_shared = nil;

+ (LRScoreManager *)shared
{
    @synchronized (self)
    {
		if (!_shared) {
			_shared = [[LRScoreManager alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init])
    {
        [self _resetScoreForNewGame];
    }
    return self;
}

#pragma mark - Word Submission + Score Calculation

- (int) submitWord:(NSDictionary *)wordDict
{
    
    //Add to the score
    int wordScore = [LRScoreManager scoreForWordWithDict:wordDict];
    self.score += wordScore;
    NSMutableDictionary *updatedWordDict = [NSMutableDictionary dictionaryWithDictionary:wordDict];
    [updatedWordDict setObject:[NSNumber numberWithInt:wordScore] forKey:@"score"];
    
    [submittedWords addObject:updatedWordDict];
    
    //Check for level progression
    if (self.score >= scoreToNextLevel)
        [self progressLevel];
    return wordScore;
}

+ (int) scoreForWordWithDict:(NSDictionary *)wordDict
{
    NSString *word = [wordDict objectForKey:@"word"];
    NSSet *loveLetterIndices = [wordDict objectForKey:@"loveLetters"];
    
    int scorePerLetter = [[LRDifficultyManager shared] scorePerLetter];
    int loveLetterMultiplier = [[LRDifficultyManager shared] loveLetterMultiplier];
    int wordLength = [word length];
    int wordScore = 0;

    //For every letter in the word...
    for (int i = 0; i < wordLength; i++) {
        //...set it equal to the base score...
        int letterScore = scorePerLetter;
        //...and if it's a love letter, multiply it by the love letter multiplier.
        if ([loveLetterIndices containsObject:@(i)]) {
            letterScore *= loveLetterMultiplier;
        }
        wordScore += letterScore;
    }
    
    //Multiply it by the lenght multiplier
    wordScore *= [LRScoreManager scoreMultiplierForLength:wordLength];
    return wordScore;
}

+ (CGFloat) scoreMultiplierForLength: (int)length
{
    CGFloat fLength = (CGFloat)length;
    CGFloat multiplier = (fLength - 1)/2;
    return multiplier;
}

#pragma mark - Game State and Level Progression

- (void)_resetScoreForNewGame {
    self.score = 0;
    scoreToNextLevel  = [[LRDifficultyManager shared] initialNextLevelScore];
    submittedWords = [NSMutableArray array];
}

- (void)progressLevel
{
    int level = [[LRDifficultyManager shared] level];
    [[LRDifficultyManager shared] setLevel:level + 1];
    
    self.lastScoreToNextLevel = scoreToNextLevel;
    IncreaseStyle levelScoreIncrease = [[LRDifficultyManager shared] levelScoreIncreaseStyle];
    
    //Increase the score needed for the next level based on the increase style
    switch (levelScoreIncrease) {
        case IncreaseStyle_None:
            scoreToNextLevel += [[LRDifficultyManager shared] initialNextLevelScore];
            break;
        case IncreaseStyle_Linear:
            scoreToNextLevel += self.lastScoreToNextLevel + [[LRDifficultyManager shared] levelScoreIncreaseFactor];
            break;
        case IncreaseStyle_Exponential:
            scoreToNextLevel += self.lastScoreToNextLevel * [[LRDifficultyManager shared] levelScoreIncreaseFactor];
            break;
    }
    NSLog(@"Level %i", [[LRDifficultyManager shared] level]);
    
}

#pragma mark - LRGameStateDelegate Methods

- (void)gameStateNewGame
{
    [self _resetScoreForNewGame];
}
@end

