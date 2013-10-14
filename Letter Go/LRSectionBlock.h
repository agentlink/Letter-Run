//
//  LRSectionBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/14/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"

@interface LRSectionBlock : LRLetterBlock

+ (LRSectionBlock*) sectionBlockWithLetter:(NSString*)letter;

- (BOOL) isLetterBlockEmpty;
- (BOOL) isLetterBlockPlaceHolder;

@end
