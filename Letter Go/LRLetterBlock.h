//
//  LRLetterBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRObject.h"



@interface LRLetterBlock : LRObject
@property NSString *letter;
@property (nonatomic, readonly) BOOL loveLetter;

+ (LRLetterBlock*) letterBlockWithLetter:(NSString*)letter loveLetter:(BOOL)love;
- (id) initWithLetter:(NSString*)letter loveLetter:(BOOL)love;

@end



