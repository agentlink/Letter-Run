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
    [generator setChainMailStyleEnabled:kLRChainMailStyleAlphabetical enabled:NO];
    XCTAssertTrue([generator isChainMailStyleEnabled:kLRChainMailStyleRandom], @"Enabling chain mail is busted");
    XCTAssertFalse([generator isChainMailStyleEnabled:kLRChainMailStyleAlphabetical], @"Disabling chain mail is busted.");
    
    [generator setChainMailStyleEnabled:kLRChainMailStyleAlphabetical enabled:YES];
    XCTAssertTrue([generator isChainMailStyleEnabled:kLRChainMailStyleReverseAlphabetical], @"Reenabling chian mail is busted");
    
    [generator setChainMailStyleEnabled:kLRChainMailStyleReverseAlphabetical | kLRChainMailStyleVowels enabled:YES];
    XCTAssertTrue([generator isChainMailStyleEnabled:kLRChainMailStyleReverseAlphabetical] && [generator isChainMailStyleEnabled:kLRChainMailStyleVowels], @"Unable to set multiple chain mail types enabled at once");
}

- (void)testEnablingRandomStart
{
    LRMultipleLetterGenerator *generator = [LRMultipleLetterGenerator new];
    [generator setRandomStartForChainMailStyle:kLRChainMailStyleVowels enabled:YES];
    [generator setRandomStartForChainMailStyle:kLRChainMailStyleRandom enabled:NO];
    XCTAssertTrue([generator isChainMailStyleUsingRandomStart:kLRChainMailStyleVowels], @"Enabling random start for chainmail styles doesn't work");
    XCTAssertFalse([generator isChainMailStyleUsingRandomStart:kLRChainMailStyleRandom], @"Disabling random start for chainmail styles doesn't work");

    [generator setRandomStartForChainMailStyle:kLRChainMailStyleVowels enabled:NO];
    XCTAssertFalse([generator isChainMailStyleUsingRandomStart:kLRChainMailStyleVowels], @"Disabling random start for chainmail styles after enabling doesn't work");

    [generator setRandomStartForChainMailStyle:kLRChainMailStyleVowels | kLRChainMailStyleRandom enabled:YES];
    XCTAssertTrue([generator isChainMailStyleUsingRandomStart:kLRChainMailStyleVowels] && [generator isChainMailStyleUsingRandomStart:kLRChainMailStyleRandom], @"Unable to set multiple chain mail types to random at once");

}

@end
