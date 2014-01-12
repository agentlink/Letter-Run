//
//  LRCappedStack.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/11/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRCappedStack : NSObject

/*!
 @description Initializes an array with an actual max capacity. Objects are popped off if the capacity would be exceeded
 @param numItems the maximum number of objects the array will hold.
 */
- (id) initWithCapacity:(NSUInteger)numItems;

/*!
 @description Pushes an object onto the stack and if it is at capacity, pops the last object off
 @return The object popped off the stack. If none was popped off, returns nil
 */
- (id) pushObject:(id)anObject;

#pragma mark - NSMutableArray functions
- (unsigned) count;
- (void) removeAllObjects;
- (id) objectAtIndex:(NSUInteger)index;
- (void) addObject:(id)anObject;

///The capacity of the stack
@property (nonatomic, readonly) NSUInteger cap;

@end
