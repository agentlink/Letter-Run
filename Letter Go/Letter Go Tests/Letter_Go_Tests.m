//
//  Letter_Go_Tests.m
//  Letter Go Tests
//
//  Created by Gabriel Nicholas on 12/13/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Letter_Go_Tests : XCTestCase

@end

@implementation Letter_Go_Tests

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

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void) testGo
{
    XCTAssertTrue(0 == 0, @"Zero equals zero");
}

@end
