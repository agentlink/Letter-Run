//
//  LRManfordAIManager.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/10/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRManfordAIManager.h"
#import "LRRowManager.h"

@interface LRManfordAIManager ()
@property (nonatomic) NSUInteger previousEnvelopeID;
@end

@implementation LRManfordAIManager

#pragma mark - Public Functions

static LRManfordAIManager *_shared = nil;
+ (LRManfordAIManager *)shared
{
    @synchronized (self) {
		if (!_shared) {
			_shared = [[LRManfordAIManager alloc] init];
		}
	}
	return _shared;
}

- (NSUInteger)nextEnvelopeIDForRow:(NSUInteger)row
{
    NSUInteger nextID = [self _generateEnvelopeIDForRow:row];
    NSAssert(nextID % kLRRowManagerNumberOfRows == row, @"Envelope ID %u does not correlate properly with row %u", (unsigned)nextID, (unsigned)row);
    self.previousEnvelopeID = nextID;
    return nextID;
}

#pragma mark - Private Functions
- (NSUInteger)_generateEnvelopeIDForRow:(NSUInteger)row
{
    NSUInteger previous = self.previousEnvelopeID;
    NSUInteger numSlots = kLRRowManagerNumberOfRows;
    NSUInteger envID = (previous/numSlots) * numSlots + numSlots;
    
    envID += row;
    return envID;
}

- (void)_resestEnvelopeIDs
{
    self.previousEnvelopeID = 0;
}

@end
