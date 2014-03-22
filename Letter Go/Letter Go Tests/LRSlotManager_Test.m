//
//  LRSlotManager_Test.m
//  Letter Go Tests
//
//  Created by Gabriel Nicholas on 12/13/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LRSlotManager.h"
#import "LRSlotManager_Private.h"
#import "LRConstants.h"
#import "LRMovingEnvelope.h"

static const int kTestCount = 200;

@interface LRSlotManager_Test : XCTestCase
@end

@implementation LRSlotManager_Test : XCTestCase

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

- (void)testSlotHistory
{
    LRSlotManager *slotManager = [LRSlotManager new];
    for (int i = 0; i < kTestCount; i++) {
        [slotManager addEnvelope:[LRMovingEnvelope movingBlockWithLetter:@"X" loveLetter:arc4random()%2]];
        int slotHistoryCount = [slotManager.slotHistory count];
        XCTAssertTrue(slotHistoryCount <= kSlotHistoryCapacity,
                      @"Error: slot history is over capacity");
        XCTAssertNotEqual(0, slotHistoryCount,
                          @"Error: slot history should not be empty after slot is added");
        
    }
}

- (void)testSlotChances {
    LRSlotManager *slotManager = [LRSlotManager new];

    for (int i = 0; i < kTestCount; i++) {
        [slotManager addEnvelope:[LRMovingEnvelope movingBlockWithLetter:@"X" loveLetter:arc4random()%2]];
        if (i < kSlotHistoryCapacity)
            continue;
        int slotChances = 0;
        for (int i = 0; i < [[slotManager slotChanceTracker] count]; i++) {
            slotChances += [[[slotManager slotChanceTracker] objectAtIndex:i] integerValue];
        }
        XCTAssertEqual(slotChances, kSlotHistoryCapacity * (kNumberOfSlots - 1), @"Error: slot chances that are too high or too low might be generated");
    }
}


@end
