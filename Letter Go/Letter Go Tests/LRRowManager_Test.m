//
//  LRRowManager_Test.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/26/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LRRowManager.h"
@interface LRRowManager_Test : XCTestCase

@end

@implementation LRRowManager_Test

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGenerateRows
{
    //generate rows should never generate the same row twice
    LRRowManager *manager = [LRRowManager new];
    int lastRow = -2;
    int testCount = 100;
    for (int i = 0; i < testCount; i++) {
        int row = [manager generateNextRow];
        XCTAssertNotEqual(row, lastRow, @"Row Manager should not generate the same row twice in a row");
        XCTAssertTrue(row < kLRRowManagerNumberOfRows, @"Number of rows should not exceed maximum of %u", (unsigned)kLRRowManagerNumberOfRows);
        lastRow = row;
    }
}

@end
