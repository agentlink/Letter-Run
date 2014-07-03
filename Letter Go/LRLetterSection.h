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

typedef NS_ENUM(NSInteger, LRDirection)
{
    kLRDirectionRight = -1,
    kLRDirectionLeft = 1
};

static NSUInteger const kLRLetterSectionCapacity = 7;
static NSUInteger const kLRLetterSectionMinimumWordLength = 3;

extern NSString * const kSubmissionKeyWord;
extern NSString * const kSubmissionKeyWordWithColors;

@interface LRLetterSection : LRScreenSection <LRLetterBlockControlDelegate>
@end
