//
//  LRScoreManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRScoreManager.h"
#import "LRConstants.h"
#import "LRGameScene.h"
#import "LRDifficultyManager.h"

@interface LRScoreManager ()
@property NSMutableArray *submittedWords;
@property (nonatomic) int score;
@end

@implementation LRScoreManager

static LRScoreManager *_shared = nil;

+ (LRScoreManager*) shared
{
    //This @synchronized line is for multithreading
    @synchronized (self)
    {
		if (!_shared)
        {
            
			_shared = [[LRScoreManager alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init])
    {
        self.score = 0;
        self.submittedWords = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame) name:GAME_STATE_NEW_GAME object:nil];
    }
    return self;
}

- (void) submitWord:(NSString*)word
{
    //Add to the score
    self.score += [LRScoreManager scoreForWord:word];
    [self.submittedWords addObject:word];
    NSLog(@"Score for word %@: %i\nTotalSCore: %i", word, [LRScoreManager scoreForWord:word], self.score);
}

#pragma mark - Getters + Setters
+ (int) scoreForWord:(NSString*)word
{
    float scoreFactor = [[LRDifficultyManager shared] totalScoreFactor];
    float baseScore = [word length] * [[LRDifficultyManager shared] scorePerLetter];
    if ([[LRDifficultyManager shared] scoreStyle] == ScoreStyle_Exponential)
        return pow(baseScore, scoreFactor);
    else
        return baseScore * scoreFactor;
}

- (int) score {
    return _score;
}

- (void) newGame {
    self.score = 0;
}

@end

