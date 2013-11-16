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
@property int scoreToNextLevel;
@property int lastScoreToNextLevel;

@end

@implementation LRScoreManager
@synthesize submittedWords;
static LRScoreManager *_shared = nil;

+ (LRScoreManager*) shared
{
    //This @synchronized line is for multithreading
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
        [self newGame];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame) name:GAME_STATE_NEW_GAME object:nil];
    }
    return self;
}

#pragma mark - Word Submission

- (void) submitWord:(NSDictionary*)wordDict
{
    
    //Add to the score
    int score = [LRScoreManager scoreForWordWithLoveLetters:wordDict];
    NSMutableDictionary *updatedWordDict = [NSMutableDictionary dictionaryWithDictionary:wordDict];
    [updatedWordDict setObject:[NSNumber numberWithInt:score] forKey:@"score"];

    [submittedWords addObject:updatedWordDict];

    //Check for level progression
    if (self.score >= self.scoreToNextLevel)
        [self progressLevel];
}

- (void) progressLevel
{
    int level = [[LRDifficultyManager shared] level];
    [[LRDifficultyManager shared] setLevel:level++];
    
    self.lastScoreToNextLevel = self.scoreToNextLevel;
    IncreaseStyle levelScoreIncrease = [[LRDifficultyManager shared] levelScoreIncreaseStyle];
    
    //Increase the score needed for the next level based on the increase style
    switch (levelScoreIncrease) {
        case IncreaseStyle_None:
            self.scoreToNextLevel += [[LRDifficultyManager shared] initialNextLevelScore];
            break;
        case IncreaseStyle_Linear:
            self.scoreToNextLevel += self.lastScoreToNextLevel + [[LRDifficultyManager shared] levelScoreIncreaseFactor];
            break;
        case IncreaseStyle_Exponential:
            self.scoreToNextLevel += self.lastScoreToNextLevel * [[LRDifficultyManager shared] levelScoreIncreaseFactor];
            break;
    }
}

#pragma mark - Getters + Setters
+ (int) scoreForWord:(NSString*)word
{
    float scoreFactor = [[LRDifficultyManager shared] scoreLengthFactor];
    float baseScore = [word length] * [[LRDifficultyManager shared] scorePerLetter];
    
    if ([[LRDifficultyManager shared] scoreIncreaseStyle] == IncreaseStyle_Exponential)
        return pow(baseScore, scoreFactor);
    else if ([[LRDifficultyManager shared] scoreIncreaseStyle] == IncreaseStyle_None)
        NSLog(@"Warning: score increase style should be linear or exponential");
    
    return baseScore * scoreFactor;
}

+ (int) scoreForWordWithLoveLetters:(NSDictionary *)wordDict
{
    int wordScore = [self scoreForWord:[wordDict objectForKey:@"word"]];
    for (int i = 0; i < [(NSSet*)[wordDict objectForKey:@"loveLetters"] count]; i++)
        wordScore += [[LRDifficultyManager shared] loveLetterBonus];
    return wordScore;
}

- (int) score {
    return _score;
}

- (void) newGame {
    self.score = 0;
    self.scoreToNextLevel  = [[LRDifficultyManager shared] initialNextLevelScore];
    submittedWords = [NSMutableArray array];
}


@end

