//
//  LRMultipleLetterGenerator.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/25/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMultipleLetterGenerator.h"
#import "NSMutableArray+Shuffle.h"

static NSUInteger const kLRMultipleLetterGeneratorListLength = 4;

@interface LRMultipleLetterGenerator ()
@property (nonatomic) int enabledChainMailStyles;
@property (nonatomic) int randomStartChainMailStyles;
@property (nonatomic, strong) NSArray *alphabetArray;
@end

@implementation LRMultipleLetterGenerator

#pragma mark - Public Methods
- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.enabledChainMailStyles = kLRChainMailStyleAlphabetical | kLRChainMailStyleReverseAlphabetical | kLRChainMailStyleVowels | kLRChainMailStyleRandom;
    //all chain mail styles start with an ordered start
    self.randomStartChainMailStyles = 0;
    [self generateMultipleLetterListWithChainMailStyle:kLRChainMailStyleAlphabetical];
    return self;
}

- (BOOL)isChainMailStyleEnabled:(LRChainMailStyle)style
{
    return (self.enabledChainMailStyles & style);
}

- (void)setChainMailStyleEnabled:(LRChainMailStyle)style enabled:(BOOL)enabled
{
    if (enabled) {
        self.enabledChainMailStyles = self.enabledChainMailStyles | style;
    }
    else {
        style = ~style;
        self.enabledChainMailStyles = self.enabledChainMailStyles & style;
    }
}

- (BOOL)isChainMailStyleUsingRandomStart:(LRChainMailStyle)style
{
    return (self.randomStartChainMailStyles & style);
}

- (void)setRandomStartForChainMailStyle:(LRChainMailStyle)style enabled:(BOOL)enabled
{
    if (enabled) {
        self.randomStartChainMailStyles = self.randomStartChainMailStyles | style;
    }
    else {
        style = ~style;
        self.randomStartChainMailStyles = self.randomStartChainMailStyles & style;
    }
}

- (NSArray *)generateMultipleLetterList
{
    LRChainMailStyle style = [self _randomAvailableChainMailStyle];
    return [self generateMultipleLetterListWithChainMailStyle:style];
}

- (NSArray *)generateMultipleLetterListWithChainMailStyle:(LRChainMailStyle)style
{
    NSArray *letterList;
    BOOL randomStart = [self isChainMailStyleUsingRandomStart:style];
    switch (style) {
        case kLRChainMailStyleAlphabetical:
            letterList = [self _multipleLetterListAlphabetical];
            break;
        case kLRChainMailStyleReverseAlphabetical:
            letterList = [self _multipleLetterListReverseAlphabetical];
            break;
        case kLRChainMailStyleRandom:
            letterList = [self _multpleLetterListRandom];
            break;
        case kLRChainMailStyleVowels:
            letterList = [self _multipleLetterListVowels];
            break;
        default:
            NSAssert(0, @"Chain mail style has no associated letter list :(");
            letterList = @[];
            break;
    }
    
    NSUInteger listLength = [self _letterListLength];
    int startingIndex = (!randomStart) ? 0 : arc4random()%(letterList.count - listLength);
    NSArray *retList = [letterList subarrayWithRange:NSMakeRange(startingIndex, listLength)];
    
    return retList;
}


#pragma mark - Private Methods

- (LRChainMailStyle)_randomAvailableChainMailStyle
{
    NSAssert(self.enabledChainMailStyles != 0, @"No chain mail styles enabled");
    LRChainMailStyle potentialStyle = 0;
    while (potentialStyle == 0) {
        potentialStyle = 1 << arc4random()%32;
        if (![self isChainMailStyleEnabled:potentialStyle]) {
            potentialStyle = 0;
        }
    }
    return (LRChainMailStyle)potentialStyle;
}

- (NSArray *)_multipleLetterListAlphabetical
{
    return self.alphabetArray;
}

- (NSArray *)_multipleLetterListReverseAlphabetical
{
    NSArray *revAlphabet = [[self.alphabetArray reverseObjectEnumerator] allObjects];
    return revAlphabet;
}

- (NSArray *)_multipleLetterListVowels
{
    NSArray *vowels = @[@"A", @"E", @"I", @"O", @"U"];
    return vowels;
}

- (NSArray *)_multpleLetterListRandom
{
    NSMutableArray *mutableAlphabet = [NSMutableArray arrayWithArray:self.alphabetArray];
    [mutableAlphabet shuffle];
    return mutableAlphabet;
}

- (NSArray *)alphabetArray
{
    if (!_alphabetArray) {
        NSString *alphabet = @"A B C D E F G H I J K L M N O P Qu R S T U V W X Y Z";
        _alphabetArray = [alphabet componentsSeparatedByString:@" "];
    }
    return _alphabetArray;
}

- (NSUInteger)_letterListLength
{
    return kLRMultipleLetterGeneratorListLength;
}

//- (NSArray *)generateMultipleLetterList;
//- (NSArray *)generateMultipleLetterListWithChainMailStyle:(LRChainMailStyle)style;
//- (NSArray *)generateMultipleLetterListWithChainMailStyle:(LRChainMailStyle)style startingLetter:(NSString *)letter;

@end
