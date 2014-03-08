//
//  LRLetterBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRGameUpdateDelegate.h"



@interface LRLetterBlock : SKSpriteNode <LRGameUpdateDelegate>

///The alphabetical letter represented by the envelope
@property (nonatomic, strong) NSString *letter;
///Whether or not the letter is a love letter
@property (nonatomic, readonly) BOOL loveLetter;

///Returns an initialized letter block
+ (LRLetterBlock*) letterBlockWithLetter:(NSString*)letter loveLetter:(BOOL)love;
///Initializes a letter block
- (id) initWithLetter:(NSString*)letter loveLetter:(BOOL)love;

@end



