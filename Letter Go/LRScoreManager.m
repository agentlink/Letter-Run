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
@property (nonatomic) NSUInteger numYellowEnvelopes;
@property (nonatomic) NSUInteger numBlueEnvelopes;
@property (nonatomic) NSUInteger numPinkEnvelopes;
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
    
    //Get the colored envelopes
    for (NSDictionary *paperColorDict in wordDict[kSubmissionKeyWordWithColors])
    {
        LRPaperColor paperColor = [[[paperColorDict allValues] firstObject] unsignedIntegerValue];
        switch (paperColor) {
            case kLRPaperColorYellow:
                self.numYellowEnvelopes++;
                break;
            case kLRPaperColorBlue:
                self.numBlueEnvelopes++;
                break;
            case kLRPaperColorPink:
                self.numPinkEnvelopes++;
                break;
            default:
                NSAssert(0, @"Paper dictionary provided invalid color");
                break;
        }
    }
    
    NSMutableDictionary *updatedWordDict = [NSMutableDictionary dictionaryWithDictionary:wordDict];
    [updatedWordDict setObject:[NSNumber numberWithInteger:wordScore] forKey:@"score"];
    NSLog(@"%@", updatedWordDict);
    
    [submittedWords addObject:updatedWordDict];
    
    //Check for level progression
    if ([[LRProgressManager shared] increasedLevelForScore:self.score]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_INCREASED_LEVEL object:nil];
        NSLog(@"Level %u", (unsigned)[[LRProgressManager shared] level]);
    }
    if (self.delegate) [self.delegate changeScoreWithAnimation:YES];
    return wordScore;
}

+ (NSUInteger)scoreForWordWithDict:(NSDictionary *)wordDict
{
    NSString *word = [wordDict objectForKey:kSubmissionKeyWord];
    
    NSUInteger wordLength = [word length];
    NSUInteger wordScore = 0;

    //For every letter in the word...
    for (int i = 0; i < wordLength; i++) {
        //...set it equal to the base score...
        NSInteger letterScore = kLRScoreManagerScorePerLetter;
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
    self.numYellowEnvelopes = 0;
    self.numBlueEnvelopes = 0;
    self.numPinkEnvelopes = 0;
    submittedWords = [NSMutableArray array];
    if (self.delegate) [self.delegate changeScoreWithAnimation:NO];
}

#pragma mark - LRGameStateDelegate Methods

- (void)gameStateNewGame
{
    [self _resetScoreForNewGame];
}

@end

