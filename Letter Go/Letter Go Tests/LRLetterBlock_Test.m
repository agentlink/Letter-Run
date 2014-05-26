//
//  LRLetterBlock_Test.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/27/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LRLetterBlock.h"
#import "LRLetterBlockBuilder.h"
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
    LRPaperColor paperColor = kLRPaperColorYellow;
    LRCollectedEnvelope *emptyBlock = [LRLetterBlockBuilder createEmptySectionBlock];
    LRCollectedEnvelope *placeholderBlock = [LRLetterBlockBuilder createPlaceHolderBlock];
    LRCollectedEnvelope *gBlock = [LRLetterBlockBuilder createBlockWithLetter:letter paperColor:paperColor];

    //Regular letter block tests
    XCTAssertEqual(letter, gBlock.letter, @"Error: section block should contain letter '%@' but instead contains '%@'", letter, gBlock.letter);
    XCTAssertEqual(paperColor, gBlock.paperColor, @"Setting the paper color for a collected envelope has failed");
    //Empty letter block test
    XCTAssertTrue([emptyBlock isCollectedEnvelopeEmpty], @"Error: isLetterBlockEmpty should be true on empty blocks");
    //Placeholder letter block tests
    XCTAssertTrue([placeholderBlock isCollectedEnvelopePlaceholder], @"Error: isLetterBlockPlaceholder should return true for placeholder blocks.");
}

@end
