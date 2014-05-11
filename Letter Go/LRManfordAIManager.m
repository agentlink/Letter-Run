//
//  LRManfordAIManager.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/10/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRManfordAIManager.h"
#import "LRRowManager.h"

NSUInteger const kLRManfordAIManagerEmptyRow = INT32_MAX;

@interface LRManfordAIManager ()
@property (nonatomic, readwrite) NSUInteger previousEnvelopeID;
@property (nonatomic, strong) NSMutableOrderedSet *selectedEnvelopes;
@end

@implementation LRManfordAIManager

#pragma mark - Set Up/ Initialization
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

- (id)init
{
    if (self = [super init]) {
        self.selectedEnvelopes = [NSMutableOrderedSet new];
    }
    return self;
}

#pragma mark - Public Methods

- (NSUInteger)nextEnvelopeIDForRow:(NSUInteger)row
{
    NSUInteger nextID = [self _generateEnvelopeIDForRow:row];
    NSAssert(nextID % kLRRowManagerNumberOfRows == row, @"Envelope ID %u does not correlate properly with row %u", (unsigned)nextID, (unsigned)row);
    self.previousEnvelopeID = nextID;
    return nextID;
}

#pragma mark - Private Methods
- (NSUInteger)_rowWithNextSelectedSlot
{
    if ([self.selectedEnvelopes count] == 0) {
        return kLRManfordAIManagerEmptyRow;
    }
    NSNumber *nextID = [self.selectedEnvelopes firstObject];
    return [nextID unsignedIntegerValue]%kLRRowManagerNumberOfRows;
}


- (NSUInteger)_generateEnvelopeIDForRow:(NSUInteger)row
{
    NSUInteger previous = self.previousEnvelopeID;
    NSUInteger numSlots = kLRRowManagerNumberOfRows;
    NSUInteger envID = (previous/numSlots) * numSlots + numSlots;
    
    envID += row;
    return envID;
}

- (void)_checkNextRowChangedFromRow:(NSUInteger)row
{
    NSUInteger nextRow = [self _rowWithNextSelectedSlot];
    if (row != nextRow) {
        [self.movementDelegate nextEnvelopeRowChangedToRow:nextRow];
    }
}

- (void)resetEnvelopeIDs
{
    self.previousEnvelopeID = 0;
    [self.selectedEnvelopes removeAllObjects];
}

#pragma mark - LRManfordAIManagerSelectionDelegate Methods
- (void)envelopeSelectedChanged:(BOOL)selected withID:(NSUInteger)uniqueID;
{
    NSUInteger nextRow = [self _rowWithNextSelectedSlot];
    NSNumber *newID = @(uniqueID);
    selected ? [self.selectedEnvelopes addObject:newID] : [self.selectedEnvelopes removeObject:newID];
    [self _checkNextRowChangedFromRow:nextRow];
}

- (void)envelopeCollectedWithID:(NSUInteger)uniqueID
{
    NSUInteger lastRow = [self _rowWithNextSelectedSlot];
    NSNumber *removedID = @(uniqueID);
    [self.selectedEnvelopes removeObject:removedID];
    [self _checkNextRowChangedFromRow:lastRow];
}

@end
