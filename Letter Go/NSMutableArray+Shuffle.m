//
//  NSMutableArray+Shuffle.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/25/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "NSMutableArray+Shuffle.h"

@implementation NSMutableArray (Shuffle)
//Stack Overflow link: http://tinyurl.com/ayewr63 (too lazy to do it myself)
- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform((unsigned)nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
