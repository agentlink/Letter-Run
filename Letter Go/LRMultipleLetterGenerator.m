//
//  LRMultipleLetterGenerator.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/25/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMultipleLetterGenerator.h"

@interface LRMultipleLetterGenerator ()
@property (nonatomic) int enabledChainMailStyles;
@end
@implementation LRMultipleLetterGenerator

#pragma mark - Public Methods
- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.enabledChainMailStyles = kLRChainMailStyleAlphabetical | kLRChainMailStyleReverseAlphabetical | kLRChainMailStyleVowels | kLRChainMailStyleRandom;
    return self;
}

- (BOOL)isChainMailStyleEnabled:(LRChainMailStyle)style
{
    return (self.enabledChainMailStyles & style);
}
- (void)setChainMailStyleEnabled:(LRChainMailStyle)style enabled:(BOOL)enabled
{
    if (enabled) {
        self.enabledChainMailStyles = self.enabledChainMailStyles | style;
    }
    else {
        style = ~style;
        self.enabledChainMailStyles = self.enabledChainMailStyles & style;
    }
}
//- (NSArray *)generateMultipleLetterList;
//- (NSArray *)generateMultipleLetterListWithChainMailStyle:(LRChainMailStyle)style;
//- (NSArray *)generateMultipleLetterListWithChainMailStyle:(LRChainMailStyle)style startingLetter:(NSString *)letter;

@end
