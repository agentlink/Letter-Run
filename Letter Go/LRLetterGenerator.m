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

static NSString* const kLetterQ = @"Q";

@interface LRLetterGenerator ()
@property NSArray *letterProbabilities;

@property NSCharacterSet *consonantSet;
@property NSCharacterSet *vowelSet;

// Vowel-Consonant Tracking
@property int vowelConstCount;

// Repeat letter tracking
@property NSString *lastLetter;
@property int repeatCount;

@end

@implementation LRLetterGenerator
@synthesize repeatCount, lastLetter, vowelConstCount;
@synthesize consonantSet, vowelSet;
@synthesize forceDropLetters;

#pragma mark - Initialization/Set Up

- (id) init
{
    if (self = [super init]) {
        vowelConstCount = 0;
        repeatCount = 1;
        [self setUpProbabilityDictionaries];
    }
    return self;
}

- (void)setUpProbabilityDictionaries
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
    consonantSet = [[self class] consonantSet];
    vowelSet = [[self class] vowelSet];

}

#pragma mark - Public Functions

static LRLetterGenerator *_shared = nil;

+ (LRLetterGenerator *)shared
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

- (NSString *)generateLetter
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
    
    NSInteger maxConsonants = [[LRDifficultyManager shared] maxNumber_consonants];
    NSInteger maxVowels = [[LRDifficultyManager shared] maxNumber_vowels];
    
    //If it's a consonant and there is a max number of consonants
    if ([consonantSet characterIsMember:[letter characterAtIndex:0]] && maxConsonants > 0) {
        //...and that max has been exceeded...
        if (vowelConstCount <= 0 - maxConsonants){
            //...generate a vowel
            letter = [self generateVowel];
            forceVowel = TRUE;
        }
        //If the last letter was a vowel, set it to a consonant count of 1
        else if (vowelConstCount >= 0)      vowelConstCount = -1;
        //Otherwise decrease the consonant count
        else                                vowelConstCount--;
    }
    
    //If it's a vowel and there is a max number of vowels...
    else if ([vowelSet characterIsMember:[letter characterAtIndex:0]] && maxVowels > 0) {
        //...and that max has been exceeded...
        if (vowelConstCount >= maxVowels) {
            //...generate a consonant
            letter = [self generateConsonant];
            forceConsonant = TRUE;
        }
        //If the last letter was a consonant, set it to a vowel count of one
        else if (vowelConstCount <= 0)      vowelConstCount = 1;
        //Otherwise, increase the vowel count
        else                                vowelConstCount++;
    }

    //Repeated letters case
    if ([lastLetter isEqualToString:letter] &&
        [[LRDifficultyManager shared] maxNumber_sameLetters] != 0) {
        if (repeatCount >= [[LRDifficultyManager shared] maxNumber_sameLetters]) {
            //Check to see if a certain letter type is being forced
            if (forceVowel)
                letter = [self generateVowel];
            else if (forceConsonant)
                letter = [self generateConsonant];
            else
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
    
    
    //Handle Qu
    if ([letter isEqualToString:kLetterQ] && [[LRDifficultyManager shared] QuEnabled]) {
        letter = kLetterQu;
    }
    
    lastLetter = letter;
    return letter;
}

+ (NSCharacterSet *)consonantSet
{
    return  [NSCharacterSet characterSetWithCharactersInString:@"BCDFGHJKLMNPQRSTVWXYZ"];
}

+ (NSCharacterSet *)vowelSet
{
    return [NSCharacterSet characterSetWithCharactersInString:@"AEIOU"];
}

#pragma mark - Private Functions

- (NSString *)generateRandomLetter {
    int letterLocation = arc4random()%[self.letterProbabilities count];
    return [self.letterProbabilities objectAtIndex:letterLocation];
}

- (NSString *)generateVowel
{
    NSString *letter = [self generateRandomLetter];
    while ([self letterTypeForString:letter] == LetterTypeConsonant)
        letter = [self generateLetter];
    return letter;
}

- (NSString *)generateConsonant
{
    NSString *letter = [self generateRandomLetter];
    while ([self letterTypeForString:letter] == LetterTypeVowel)
        letter = [self generateLetter];
    return letter;
}

- (LetterType) letterTypeForString:(NSString *)letter
{
    //If there is more than one letter...
    if ([letter length] > 1) {
        //...and that letter is not Qu
        if ([[LRDifficultyManager shared] QuEnabled] && [letter isEqualToString:kLetterQu]) {
            return LetterTypeConsonant;
        }
        //...return LetterTypeNone
        return LetterTypeNone;
    }
    //Consonant
    else if ([consonantSet characterIsMember:[letter characterAtIndex:0]]) {
        return LetterTypeConsonant;
    }
    //Vowel
    else if ([vowelSet characterIsMember:[letter characterAtIndex:0]]) {
        return LetterTypeVowel;
    }
    return LetterTypeNone;
}

@end
