//
//  LRManfordAIManager.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/10/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRManfordAIManager.h"
#import "LRRowManager.h"

static NSUInteger const kLRManfordAIManagerEmptyRow = INT32_MAX;

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

- (NSUInteger)rowWithNextSelectedSlot
{
    if ([self.selectedEnvelopes count] == 0) {
        return kLRManfordAIManagerEmptyRow;
    }
    NSNumber *nextID = [self.selectedEnvelopes firstObject];
    return [nextID unsignedIntegerValue]%kLRRowManagerNumberOfRows;
}

#pragma mark - Private Methods
- (NSUInteger)_generateEnvelopeIDForRow:(NSUInteger)row
{
    NSUInteger previous = self.previousEnvelopeID;
    NSUInteger numSlots = kLRRowManagerNumberOfRows;
    NSUInteger envID = (previous/numSlots) * numSlots + numSlots;
    
    envID += row;
    return envID;
}

- (void)resetEnvelopeIDs
{
    self.previousEnvelopeID = 0;
    [self.selectedEnvelopes removeAllObjects];
}

#pragma mark - LRManfordAIManagerSelectionDelegate Methods
- (void)envelopeSelectedChanged:(BOOL)selected withID:(NSUInteger)uniqueID;
{
    NSNumber *newID = @(uniqueID);
    selected ? [self.selectedEnvelopes addObject:newID] : [self.selectedEnvelopes removeObject:newID];
    NSLog(@"Next envelope location: %u", (unsigned)[self rowWithNextSelectedSlot]);
}

- (void)envelopeCollectedWithID:(NSUInteger)uniqueID
{
    NSNumber *removedID = @(uniqueID);
    [self.selectedEnvelopes removeObject:removedID];
    NSLog(@"Next envelope location: %u", (unsigned)[self rowWithNextSelectedSlot]);

}

@end
