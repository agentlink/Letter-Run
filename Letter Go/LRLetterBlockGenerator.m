//
//  LRLetterBlockGenerator.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlockGenerator.h"
#import "LRConstants.h"
#import "LRLetterGenerator.h"

#define LETTER_BLOCK_SIZE           48

@implementation LRLetterBlockGenerator

#pragma mark - Falling Letters

+ (LRLetterBlock*) createLetterBlock
{

    NSString *label = [[LRLetterGenerator shared] generateLetter];
    LRLetterBlock *letterBlock = [LRLetterBlock letterBlockWithSize:CGSizeMake(LETTER_BLOCK_SIZE, LETTER_BLOCK_SIZE) andLetter:label];
    letterBlock.position = CGPointMake(0, 200);
    
    return letterBlock;
}

+ (LRLetterBlock*) createEmptyLetterBlock
{
    LRLetterBlock *lb = [LRLetterBlock letterBlockWithSize:CGSizeMake(LETTER_BLOCK_SIZE, LETTER_BLOCK_SIZE) andLetter:@""];
    [lb removePhysics];
    lb.movementEnabled = NO;
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

+ (LRLetterSlot*) createSlotWithLetterBlock:(LRLetterBlock*)block
{
    return [[LRLetterSlot alloc] initWithLetterBlock:block];
}

+ (LRLetterSlot*) createSlotWithLetter:(NSString*)letter;
{
    LRLetterBlock *block = [self createBlockForSlotWithLetter:letter];
    return [[LRLetterSlot alloc] initWithLetterBlock:block];
}

+ (LRLetterSlot*) createSlotWithEmptyLetterBlock
{
    LRLetterBlock *block = [self createBlockForSlotWithLetter:@""];
    return [[LRLetterSlot alloc] initWithLetterBlock:block];
}
@end
