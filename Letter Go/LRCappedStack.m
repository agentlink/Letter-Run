//
//  LRCappedStack.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/11/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRCappedStack.h"

@interface LRCappedStack ()
@property (nonatomic, readwrite) NSUInteger cap;
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation LRCappedStack

#pragma mark - Capped Stack public functions

- (id) init {
    NSAssert(0, @"Error: capped stack must be initialized with a capacity");
    return self;
}

- (id) initWithCapacity:(NSUInteger)numItems
{
    if (self = [super init]) {
        self.cap = numItems;
        self.array = [[NSMutableArray alloc] initWithCapacity:numItems];
    }
    return self;
}



- (id) pushObject:(id)anObject {
    //If it's at capacity,
    id object = ([self.array count] == self.cap) ? [self.array lastObject] : nil;
    [self addObject:anObject];
    return object;
}

#pragma mark - NSMutableArray Functions

- (void)addObject:(id)anObject {
    if ([self.array count] == self.cap) {
        [self.array removeLastObject];
    }
    [self.array insertObject:anObject atIndex:0];
}

- (NSUInteger) count {
    return [self.array count];
}

- (void)removeAllObjects {
    [self.array removeAllObjects];
}

- (id) objectAtIndex:(NSUInteger)index {
    return [self.array objectAtIndex:index];
}

- (NSString *)description {
    return [self.array description];
}
@end
