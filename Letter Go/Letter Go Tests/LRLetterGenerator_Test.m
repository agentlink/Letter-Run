//
//  LRLetterGeneration_Test.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/13/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LRLetterGenerator.h"
#import "LRDifficultyManager.h"

@interface LRLetterGenerator_Test : XCTestCase

@end

static const unsigned trialCount = 1000;

@implementation LRLetterGenerator_Test

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testBuildLetterGenerator
{
    XCTAssertNotNil([LRLetterGenerator shared], @"Letter generator should not be nil");
}

//Check to see if more than the max number of vowels, consonants, or repeated letters is produced
- (void)testLetterSetLimitations
{
    NSArray *letterArray = [self generateLetterArrayWithCount:trialCount];
    [self testArrayForLetterType:LetterTypeConsonant array:letterArray];
    [self testArrayForLetterType:LetterTypeVowel array:letterArray];
    [self testArrayForRepetition:letterArray];
    
    /* Tests that should fail
     [self testArrayForLetterType:LetterTypeConsonant array:@[@"X", @"X,", @"X", @"X", @"X" @"E"]];
     [self testArrayForLetterType:LetterTypeVowel array:@[@"A", @"A", @"A", @"A"]];
     [self testArrayForRepetition:@[@"A", @"A", @"A", @"A"]];
     */
}



- (NSArray*) generateLetterArrayWithCount:(NSUInteger)count
{
    NSMutableArray *letterArray = [NSMutableArray new];
    for (int i = 0; i < count; i++)
    {
        NSString *letter = [[LRLetterGenerator shared] generateLetter];
        [letterArray addObject:letter];
    }
    return letterArray;
}

- (void) testArrayForLetterType:(LetterType)letterType array:(NSArray*)letterArray
{
    if (!letterArray)
        letterArray = [self generateLetterArrayWithCount:trialCount];

    //Declare letter type dependent variables
    NSUInteger maxLetterCount;
    NSCharacterSet *letterSet;
    NSString *letterTypeDescriptor;
    if (letterType == LetterTypeConsonant) {
        maxLetterCount = [[LRDifficultyManager shared] maxNumber_consonants];
        letterSet = [LRLetterGenerator consonantSet];
        letterTypeDescriptor = @"consonant";
    }
    else {
        maxLetterCount = [[LRDifficultyManager shared] maxNumber_vowels];
        letterSet = [LRLetterGenerator vowelSet];
        letterTypeDescriptor = @"vowel";
    }
    
    //Create the smaller array that will iterate through the larger one
    NSUInteger checkArraySize = maxLetterCount + 1;
    NSMutableArray *checkArray = [NSMutableArray arrayWithCapacity:checkArraySize];
    
    //Make sure max number of consonants is not exceeded
    for (int i = 0; i < [letterArray count] - maxLetterCount; i++)
    {
        //Iterate the subarray through and check to see if bounds are exceeded
        checkArray = [NSMutableArray arrayWithArray:[letterArray subarrayWithRange:
                                                     (NSRange){i, checkArraySize}]];
        BOOL illegal = [self arrayContainsIllegalCharactersFromSet:letterSet letterArray:checkArray];
        XCTAssertFalse(illegal, @"Array %@ contains more than the max number of %@s (%i) ", [checkArray description], letterTypeDescriptor, maxLetterCount);
    }
}

- (void) testArrayForRepetition:(NSArray*)letterArray
{
    if (!letterArray)
        letterArray = [self generateLetterArrayWithCount:trialCount];
    
    //Declare letter type dependent variables
    NSUInteger maxLetterCount = [[LRDifficultyManager shared] maxNumber_sameLetters];
    NSUInteger checkArraySize = maxLetterCount + 1;
    NSMutableArray *checkArray = [NSMutableArray arrayWithCapacity:checkArraySize];
    
    for (int i = 0; i < [letterArray count] - maxLetterCount; i++)
    {
        checkArray = [NSMutableArray arrayWithArray:[letterArray subarrayWithRange:
                                                     (NSRange){i, checkArraySize}]];
        BOOL illegal = [self arrayContainsAllRepeatingCharacters:checkArray];
        XCTAssertFalse(illegal, @"Array %@ contains more than max number of repeating characters (%i)", [checkArray description], maxLetterCount);
    }

}

- (BOOL) arrayContainsIllegalCharactersFromSet:(NSCharacterSet*)charSet letterArray:(NSArray*)letterArray
{
    //Get the list of consonants
    for (NSString *letter in letterArray)
    {
        //If anything in there is not a consonant, return true
        if (![charSet characterIsMember:[letter characterAtIndex:0]])
            return false;
    }
    //Otherwise, return false
    return true;
}

- (BOOL) arrayContainsAllRepeatingCharacters:(NSArray*)array
{
    NSSet *set = [NSSet setWithArray:array];
    return ([set count] <= 1);
}

@end
