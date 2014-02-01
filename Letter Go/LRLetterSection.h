//
//  LRLetterSection.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRLetterBlockControlDelegate.h"
#import "LRScreenSection.h"

@interface LRLetterSection : LRScreenSection <LRLetterBlockControlDelegate>

- (int) numLettersInSection;
- (void) clearLetterSectionAnimated:(BOOL)animated;

@end
