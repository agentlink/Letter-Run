//
//  LRSlotManager_Test.m
//  Letter Go Tests
//
//  Created by Gabriel Nicholas on 12/13/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LRSlotManager.h"

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
    int val = [slotManager generateNextSlot];
    for (int i = 0; i < kTestCount; i++) {
        int temp = [slotManager generateNextSlot];
        XCTAssertNotEqual(temp, val, @"Slot manager should not generate the same slot twice");
        temp = val;
    }
}


@end
