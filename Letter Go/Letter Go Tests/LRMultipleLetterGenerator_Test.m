//
//  LRMultipleLetterGenerator_Test.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/25/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMultipleLetterGenerator.h"
#import <XCTest/XCTest.h>

@interface LRMultipleLetterGenerator_Test : XCTestCase

@end

@implementation LRMultipleLetterGenerator_Test

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

- (void)testEnablingChainMail
{
    LRMultipleLetterGenerator *generator = [LRMultipleLetterGenerator new];
    [generator setChainMailStyleEnabled:kLRChainMailStyleRandom enabled:YES];
    XCTAssertTrue([generator isChainMailStyleEnabled:kLRChainMailStyleRandom], @"Enabling chain mail is busted");
    [generator setChainMailStyleEnabled:kLRChainMailStyleAlphabetical enabled:NO];
    XCTAssertFalse([generator isChainMailStyleEnabled:kLRChainMailStyleAlphabetical], @"Disabling chain mail is busted.");
    [generator setChainMailStyleEnabled:kLRChainMailStyleAlphabetical enabled:YES];
    XCTAssertTrue([generator isChainMailStyleEnabled:kLRChainMailStyleReverseAlphabetical], @"Reenabling chian mail is busted");
}

@end
