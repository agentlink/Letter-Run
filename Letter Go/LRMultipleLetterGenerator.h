//
//  LRMultipleLetterGenerator.h
//  Letter Go
//
//  Created by Gabe Nicholas on 5/25/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, LRChainMailStyle)
{
    kLRChainMailStyleAlphabetical = 0x1 << 0,
    kLRChainMailStyleReverseAlphabetical = 0x1 << 1,
    kLRChainMailStyleVowels = 0x1 << 2,
    kLRChainMailStyleRandom = 0x1 << 3
};

@interface LRMultipleLetterGenerator : SKNode

- (void)setChainMailStyleEnabled:(LRChainMailStyle)style enabled:(BOOL)enabled;
- (BOOL)isChainMailStyleEnabled:(LRChainMailStyle)style;

- (NSArray *)generateMultipleLetterList;
- (NSArray *)generateMultipleLetterListWithChainMailStyle:(LRChainMailStyle)style;
- (NSArray *)generateMultipleLetterListWithChainMailStyle:(LRChainMailStyle)style startingLetter:(NSString *)letter;

@end
