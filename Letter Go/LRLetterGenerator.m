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

@property NSCharacterSet *consonantSet;
@property NSCharacterSet *vowelSet;

@property int vowelConstCount;

@property NSString *lastLetter;
@property int repeatCount;

@end

@implementation LRLetterGenerator
@synthesize repeatCount, lastLetter, vowelConstCount;
@synthesize consonantSet, vowelSet;
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
        repeatCount = 1;
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
    consonantSet = [NSCharacterSet characterSetWithCharactersInString:@"BCDFGHJKLMNPQRSTVWXYZ"];
    vowelSet = [NSCharacterSet characterSetWithCharactersInString:@"AEIOU"];

}

#pragma mark - Letter Generation Functions

- (NSString*)generateLetter
{
    BOOL forceConsonant = FALSE;
    BOOL forceVowel = FALSE;
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
    
    if ([consonantSet characterIsMember:[letter characterAtIndex:0]] && maxConsonants > 0) {
        if (vowelConstCount <= 0 - maxConsonants){
            letter = [self generateVowel];
            forceVowel = TRUE;
        }
        else if (vowelConstCount >= 0)      vowelConstCount = -1;
        else                                vowelConstCount--;
    }
    else if ([vowelSet characterIsMember:[letter characterAtIndex:0]] && maxVowels > 0) {
        if (vowelConstCount >= maxVowels) {
            letter = [self generateConsonant];
            forceConsonant = TRUE;
        }
        else if (vowelConstCount <= 0)      vowelConstCount = 1;
        else                                vowelConstCount++;
    }

    //Repeated letters case
    if ([lastLetter isEqualToString:letter] &&
        [[LRDifficultyManager shared] maxNumber_sameLetters] != 0) {
        if (repeatCount >= [[LRDifficultyManager shared] maxNumber_sameLetters]) {
            letter = [self generateLetter];
            repeatCount = 1;
        }
        else {
            repeatCount++;
        }
    }
    else {
        repeatCount = 1;
    }
    if (forceVowel)             vowelConstCount = 1;
    else if (forceConsonant)    vowelConstCount = -1;
    
    lastLetter = letter;
    return letter;
}

- (NSString*) generateRandomLetter {
    int letterLocation = arc4random()%[self.letterProbabilities count];
    return [self.letterProbabilities objectAtIndex:letterLocation];
}

- (NSString*)generateVowel
{
    NSString *letter = [self generateRandomLetter];
    while ([consonantSet characterIsMember:[letter characterAtIndex:0]])
        letter = [self generateLetter];
    return letter;
}

- (NSString*)generateConsonant
{
    vowelConstCount = 0;
    NSString *letter = [self generateRandomLetter];
    while ([vowelSet characterIsMember:[letter characterAtIndex:0]])
        letter = [self generateLetter];
    return letter;
}
@end
