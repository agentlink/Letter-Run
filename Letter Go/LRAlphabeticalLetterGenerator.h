//
//  LRLetterGenerator.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRLetterBlock.h"

extern const NSUInteger kLRLetterGeneratorMaxConsonants;
extern const NSUInteger kLRLetterGeneratorMaxVowels;
extern const NSUInteger kLRLetterGeneratorMaxRepeatLetters;

typedef NS_ENUM(NSUInteger, LetterType)
{
    LetterTypeConsonant = 0,
    LetterTypeVowel,
    LetterTypeNone
};

static NSString* const kLetterQu = @"Qu";


@interface LRAlphabeticalLetterGenerator : SKNode

///Returns the shared instance of the letter generator
+ (LRAlphabeticalLetterGenerator *)shared;

///Returns a letter generated from the limitations set in the difficulty manager
- (NSString *)generateLetterForPaperColor:(LRPaperColor)color;

///Returns the set of all consonants
+ (NSCharacterSet *)consonantSet;
///Returns the set of all vowels
+ (NSCharacterSet *)vowelSet;
///Returns whether the string is a consonant or vowel
- (LetterType)letterTypeForString:(NSString *)letter;

@property NSMutableArray *forceDropLetters;

@end
