//
//  LRScoreManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRScoreManager.h"
#import "LRProgressManager.h"
#import "LRGameScene.h"
#import "LRDifficultyManager.h"

NSUInteger const kLRScoreManagerScorePerLetter = 10;

@interface LRScoreManager ()
@property (nonatomic) NSUInteger score;
@end

@implementation LRScoreManager
@synthesize submittedWords;
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

- (NSUInteger)submitWord:(NSDictionary *)wordDict
{
    
    //Add to the score
    NSInteger wordScore = [LRScoreManager scoreForWordWithDict:wordDict];
    self.score += wordScore;
    NSMutableDictionary *updatedWordDict = [NSMutableDictionary dictionaryWithDictionary:wordDict];
    [updatedWordDict setObject:[NSNumber numberWithInteger:wordScore] forKey:@"score"];
    NSLog(@"%@", updatedWordDict);
    
    [submittedWords addObject:updatedWordDict];
    
    //Check for level progression
    if ([[LRProgressManager shared] increasedLevelForScore:self.score]) {
        NSLog(@"Level %u", [[LRProgressManager shared] level]);
    }
    return wordScore;
}

+ (NSUInteger)scoreForWordWithDict:(NSDictionary *)wordDict
{
    NSString *word = [wordDict objectForKey:@"word"];
    NSSet *loveLetterIndices = [wordDict objectForKey:@"loveLetters"];
    
    NSInteger loveLetterMultiplier = [[LRDifficultyManager shared] loveLetterMultiplier];
    NSUInteger wordLength = [word length];
    NSUInteger wordScore = 0;

    //For every letter in the word...
    for (int i = 0; i < wordLength; i++) {
        //...set it equal to the base score...
        NSInteger letterScore = kLRScoreManagerScorePerLetter;
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

+ (CGFloat)scoreMultiplierForLength: (NSUInteger)length
{
    CGFloat fLength = (CGFloat)length;
    CGFloat multiplier = (fLength - 1)/2;
    return multiplier;
}

#pragma mark - Game State and Level Progression

- (void)_resetScoreForNewGame {
    self.score = 0;
    submittedWords = [NSMutableArray array];
}

#pragma mark - LRGameStateDelegate Methods

- (void)gameStateNewGame
{
    [self _resetScoreForNewGame];
}
@end

