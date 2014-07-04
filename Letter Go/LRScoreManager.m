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

NSUInteger const kLRScoreManagerScorePerLetter = 10;

@interface LRScoreManager ()
@property (nonatomic) NSUInteger score;
@property (nonatomic) NSUInteger distance;
@property (nonatomic) NSUInteger lettersCollected;
@property (nonatomic, strong) NSMutableArray *numEnvelopes;
@property (nonatomic, strong) NSMutableArray *wordLengths;
@property (nonatomic, strong) NSMutableArray *collectedWords;
@end

@implementation LRScoreManager
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
        self.numEnvelopes = [NSMutableArray new];
        self.wordLengths = [NSMutableArray new];
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
    
    //Get the colored envelopes and store the value
    for (NSDictionary *paperColorDict in wordDict[kSubmissionKeyWordWithColors])
    {
        LRPaperColor paperColor = [[[paperColorDict allValues] firstObject] unsignedIntegerValue];
        NSNumber *currentVal = self.numEnvelopes[paperColor];
        self.numEnvelopes[paperColor] = @([currentVal integerValue] + 1);
        self.lettersCollected++;
    }
    
    //Get the length of the word and store the value
    NSString *word = wordDict[@"word"];
    NSUInteger length = [word length];
    self.wordLengths[length] = @([self.wordLengths[length] integerValue] + 1);
    
    NSMutableDictionary *updatedWordDict = [NSMutableDictionary dictionaryWithDictionary:wordDict];
    [updatedWordDict setObject:[NSNumber numberWithInteger:wordScore] forKey:@"score"];
    
    [self.collectedWords addObject:updatedWordDict];
    
    //Check for level progression
    if ([[LRProgressManager shared] didIncreaseLevel]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_FINISHED_LEVEL object:nil];
        NSLog(@"Level %u", (unsigned)[[LRProgressManager shared] level]);
        [self _resetScoreForNewGame];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeScoreWithAnimation:)]) {
        [self.delegate changeScoreWithAnimation:YES];
    }
    return wordScore;
}

- (NSUInteger)envelopesCollectedForColor:(LRPaperColor)paperColor
{
    NSUInteger val = 0;
    if (paperColor != kLRPaperColorNone)
    {
        val = [[self.numEnvelopes objectAtIndex:paperColor] unsignedIntegerValue];
    }
    else
    {
        for (NSNumber *num in self.numEnvelopes)
        {
            val += [num integerValue];
        }
    }
    return val;
}

- (NSUInteger)wordsCollectedForLength:(NSUInteger)length
{
    return [self.wordLengths[length] unsignedIntegerValue];
}

+ (NSUInteger)scoreForWordWithDict:(NSDictionary *)wordDict
{
    NSArray *letterArray = wordDict[kSubmissionKeyWordWithColors];
    NSUInteger wordScore = 0;

    //For every letter in the word...
    for (NSDictionary *letterDict in letterArray)
    {
        NSAssert([letterDict count] == 1, @"Letter dicts should not have more than one key/value pair in them");
        LRPaperColor color = [[[letterDict allValues] firstObject] integerValue];
        NSInteger letterScore = [LRScoreManager _scoreForPaperColor:color];
        wordScore += letterScore;
    }
    return wordScore;
}

- (void)increaseDistanceByValue:(NSUInteger)distance
{
    self.distance += distance;
}

- (NSArray *)submittedWords
{
    return self.collectedWords;
}

#pragma Private Methods

+ (NSInteger)_scoreForPaperColor:(LRPaperColor)color
{
    return (color + 1) * kLRScoreManagerScorePerLetter;
}

- (void)_resetScoreForNewLevel
{
    for (int i = 0; i <= kLRPaperColorHighestValue; i++)
    {
        self.numEnvelopes[i] = @(0);
    }
    for (int i = 0; i <= kLRLetterSectionCapacity; i++)
    {
        self.wordLengths[i] = @(0);
    }
    self.lettersCollected = 0;

}

- (void)_resetScoreForNewGame {
    //Clear all the scores
    self.score = 0;
    self.distance = 0;
    [self _resetScoreForNewLevel];
    
    //Empty the submitted owrds array
    self.collectedWords = [NSMutableArray array];
    
    //And update the score shown on screen
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeScoreWithAnimation:)]) {
        [self.delegate changeScoreWithAnimation:NO];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeDistance)]) {
        [self.delegate changeDistance];
    }
}

- (void)setDistance:(NSUInteger)distance
{
    _distance = distance;
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeDistance)]) {
        [self.delegate changeDistance];
    }
}

#pragma mark - LRGameStateDelegate Methods

- (void)gameStateNewGame
{
    [self _resetScoreForNewGame];
}

@end

