//
//  LRLetterGenerator.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRLetterGenerator : SKNode

///Returns the shared instance of the letter generator
+ (LRLetterGenerator*) shared;

///Returns a letter generated from the limitations set in the difficulty manager
- (NSString*)generateLetter;

///Returns the set of all consonants
+ (NSCharacterSet*) consonantSet;
///Returns the set of all vowels
+ (NSCharacterSet*) vowelSet;


@property NSMutableArray *forceDropLetters;

@end
