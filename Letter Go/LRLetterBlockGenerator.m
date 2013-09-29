//
//  LRLetterBlockGenerator.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlockGenerator.h"
@implementation LRLetterBlockGenerator

- (id) init
{
    if (self = [super init])
    {
        
    }
    return self;
}

+ (LRLetterBlock*) createLetterBlock
{
    //This will actually call LRLetterGenerator to get the string, but for now, it's a random unicode character
    // A = 65
    // Z = 90
    unsigned short unicodeValue = arc4random()%26 + 65;
    NSString *label = [NSString stringWithFormat:@"%C", unicodeValue];
    LRLetterBlock *letterBlock = [LRLetterBlock letterBlockWithSize:CGSizeMake(50, 50) andLetter:label];
    letterBlock.position = CGPointMake(0, 300);
    
    return letterBlock;
}


@end
