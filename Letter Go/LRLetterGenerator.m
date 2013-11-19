//
//  LRLetterGenerator.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterGenerator.h"
#import "LRDifficultyManager.h"

#define PROBABILITY_DICT            @"Scrabble"

@interface LRLetterGenerator ()
@property NSArray *letterProbabilities;

@property NSSet *consonantSet;
@property NSSet *vowelSet;
@property int vowelConstCount;

@property NSString *lastLetter;
@property int repeatCount;

@end

@implementation LRLetterGenerator
@synthesize repeatCount, lastLetter, vowelConstCount;
@synthesize forceDropLetters;

static LRLetterGenerator *_shared = nil;

+ (LRLetterGenerator*) shared
{
    //This @synchronized line is for multithreading
    @synchronized (self)
    {
		if (!_shared)
        {
			_shared = [[LRLetterGenerator alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init]) {
        vowelConstCount = 0;
        repeatCount = 0;
        [self setUpProbabilityDictionaries];
    }
    return self;
}

- (void) setUpProbabilityDictionaries
{
    //Load general probability dictionary
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LetterProbabilities" ofType:@"plist"];
    NSDictionary *probabilityDict = [[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:PROBABILITY_DICT];
    NSMutableArray *letterArray = [NSMutableArray array];
    for (NSString* key in [probabilityDict allKeys])
    {
        int letterProbability = [[probabilityDict objectForKey:key] intValue];
        for (int i = 0; i < letterProbability; i++)
        {
            [letterArray addObject:key];
        }
    }
    self.letterProbabilities = letterArray;
    
    //Create vowel and consonant sets
    //TODO: Replace these with NSCharacterSets
    self.consonantSet = [NSSet setWithObjects: @"B", @"C", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"M", @"N", @"P", @"Q", @"R", @"S", @"T", @"V", @"W", @"X", @"Z", nil];
    self.vowelSet = [NSSet setWithObjects:@"A", @"E", @"I", @"O", @"U", nil];


}

#pragma mark - Letter Generation Functions

- (NSString*)generateLetter
{
    if ([forceDropLetters count])
        return [forceDropLetters objectAtIndex:0];
    NSString *letter = [self generateRandomLetter];
    
    /*
     vowelConstCount works by consonants being negative and vowels being positive.
     If the count gets too high/low for either one, it puts out the opposite. If a streak
     is broken, it starts over
     
     Vowels are positive
     Consonants are negative
    */
    
    int maxConsonants = [[LRDifficultyManager shared] maxNumber_consonants];
    int maxVowels = [[LRDifficultyManager shared] maxNumber_vowels];
    
    if ([self.consonantSet containsObject:letter] && maxConsonants > 0) {
        if (vowelConstCount == 0 - maxConsonants)      letter = [self generateVowel];
        else if (vowelConstCount >= 0)                 vowelConstCount = -1;
        else                                           vowelConstCount--;
    }
    else if ([self.vowelSet containsObject:letter] && maxVowels > 0) {
        if (vowelConstCount == maxVowels)              letter = [self generateConsonant];
        else if (vowelConstCount <= 0)                 vowelConstCount = 1;
        else                                           vowelConstCount++;
    }
    
    //Repeated letters case
    if ([[LRDifficultyManager shared] maxNumber_sameLetters] == 0)
        return letter;
    if ([lastLetter isEqualToString:letter]) {
        if (repeatCount > [[LRDifficultyManager shared] maxNumber_sameLetters]) {
            letter = [self generateLetter];
            repeatCount = 1;
        }
        else {
            repeatCount++;
        }
    }
    lastLetter = letter;
    return letter;
}

- (NSString*) generateRandomLetter {
    int letterLocation = arc4random()%[self.letterProbabilities count];
    return [self.letterProbabilities objectAtIndex:letterLocation];
}

//TODO: Make these nicer

- (NSString*)generateVowel
{
    NSString *letter = [self generateRandomLetter];
    while ([self.consonantSet containsObject:letter])
        letter = [self generateLetter];
    return letter;
}

- (NSString*)generateConsonant
{
    NSString *letter = [self generateRandomLetter];
    while ([self.vowelSet containsObject:letter])
        letter = [self generateLetter];
    return letter;
}
@end
