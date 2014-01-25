//
//  LRLetterBlock_Test.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/27/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LRLetterBlock.h"
#import "LRLetterBlockGenerator.h"
#import "LRFallingEnvelope.h"
#import "LRCollectedEnvelope.h"
#import "LRConstants.h"

@interface LRLetterBlock_Test : XCTestCase

@end

@implementation LRLetterBlock_Test

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

- (void)testLetterBlockLabels
{
    NSString *letter = @"G";
    BOOL love = YES;
    LRCollectedEnvelope *emptyBlock = [LRLetterBlockGenerator createEmptySectionBlock];
    LRCollectedEnvelope *placeholderBlock = [LRLetterBlockGenerator createPlaceHolderBlock];
    LRCollectedEnvelope *gBlock = [LRLetterBlockGenerator createBlockWithLetter:letter loveLetter:love];

    //Regular letter block tests
    XCTAssertEqual(letter, gBlock.letter, @"Error: section block should contain letter '%@' but instead contains '%@'", letter, gBlock.letter);

    //Empty letter block test
    XCTAssertTrue([emptyBlock isLetterBlockEmpty], @"Error: isLetterBlockEmpty should be true on empty blocks");
    
    //Placeholder letter block tests
    XCTAssertTrue([placeholderBlock isLetterBlockPlaceHolder], @"Error: isLetterBlockPlaceholder should return true for placeholder blocks.");
    
}

@end
