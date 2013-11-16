//
//  LRSectionBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/14/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"

@interface LRSectionBlock : LRLetterBlock

+ (LRSectionBlock*) sectionBlockWithLetter:(NSString*)letter loveLetter:(BOOL)love;;
+ (LRSectionBlock*) emptySectionBlock;

- (BOOL) isLetterBlockEmpty;
- (BOOL) isLetterBlockPlaceHolder;

@end
