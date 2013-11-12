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
@property NSMutableArray *submittedWords;
@property (nonatomic) int score;
@property int scoreToNextLevel;
@property int lastScoreToNextLevel;
@end

@implementation LRScoreManager

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

- (void) submitWord:(NSString*)word
{
    //Add to the score
    self.score += [LRScoreManager scoreForWord:word];
    [self.submittedWords addObject:word];
    //NSLog(@"Score for word %@: %i\nTotalSCore: %i", word, [LRScoreManager scoreForWord:word], self.score);
    
    //If the player has made it to the next level
    if (self.score >= self.scoreToNextLevel) {

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
        //NSLog(@"Increased level!\nCurrent score: %i\nScore for next level:%i", self.score, self.scoreToNextLevel);
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

- (int) score {
    return _score;
}

- (void) newGame {
    self.score = 0;
    self.scoreToNextLevel  = [[LRDifficultyManager shared] initialNextLevelScore];
    self.submittedWords = [NSMutableArray array];
}

@end

