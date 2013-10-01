//
//  LRLetterBlockGenerator.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlockGenerator.h"
#import "LRNameConstants.h"

#define LETTER_BLOCK_SIZE           48

@implementation LRLetterBlockGenerator

#pragma mark - Falling Letters

+ (LRLetterBlock*) createLetterBlock
{
    //This will actually call LRLetterGenerator to get the string, but for now, it's a random unicode character
    // A = 65
    // Z = 90
    unsigned short unicodeValue = arc4random()%26 + 65;
    NSString *label = [NSString stringWithFormat:@"%C", unicodeValue];
    LRLetterBlock *letterBlock = [LRLetterBlock letterBlockWithSize:CGSizeMake(LETTER_BLOCK_SIZE, LETTER_BLOCK_SIZE) andLetter:label];
    letterBlock.position = CGPointMake(0, 200);
    
    return letterBlock;
}

+ (LRLetterBlock*) createEmptyLetterBlock
{
    LRLetterBlock *lb = [LRLetterBlock letterBlockWithSize:CGSizeMake(LETTER_BLOCK_SIZE, LETTER_BLOCK_SIZE) andLetter:@""];
    lb.physicsBody = nil;
    lb.color = [SKColor whiteColor];
    lb.name = NAME_EMPTY_LETTER_SLOT;
    return lb;
}

#pragma mark - Letter Slots
+ (LRLetterBlock*) createBlockForSlotWithLetter:(NSString*)letter
{
    LRLetterBlock *lb = [LRLetterBlock letterBlockWithSize:CGSizeMake(LETTER_BLOCK_SIZE, LETTER_BLOCK_SIZE) andLetter:letter];
    [lb removePhysics];
    lb.movementEnabled = NO;
    return lb;
}
@end
