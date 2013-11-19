//
//  LRLetterGenerator.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRLetterGenerator : SKNode

+ (LRLetterGenerator*) shared;
- (NSString*)generateLetter;

@property NSMutableArray *forceDropLetters;

@end
