//
//  LRLetterSection.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRScreenSection.h"

typedef enum  {
    LetterSectionStateNormal,
    LetterSectionStateSubmittingWord,
    LetterSectionStateAddingLetter,
    LetterSectionStateRemovingLetter,
    LetterSectionStateRearranging
} LetterSectionState;

@interface LRLetterSection : LRScreenSection

@property LetterSectionState currentState;

- (int) numLettersInSection;

@end
