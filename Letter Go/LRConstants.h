
//  LRConstants.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

//Leter Properties
static const NSUInteger kLRRowManagerNumberOfRows = 3;
static const NSUInteger kLRLetterSectionCapacity = 7;

//Screen section constants
static const CGFloat kSectionHeightButtonSection  =       60.0;
static const CGFloat kSectionHeightLetterSection  =       65.0;
static const CGFloat kSectionHeightHealthSection  =       18.0;

typedef void(^CompletionBlockType)(void);

#define kSectionHeightTopMenuSection         (IS_IPHONE_5 ? 108.0 : 90)

#define kSectionHeightMainSection           (SCREEN_HEIGHT - kSectionHeightLetterSection - kSectionHeightHealthSection - kSectionHeightButtonSection - kSectionHeightTopMenuSection)


//Collected Envelope properties
#define kCollectedEnvelopeSpriteDimension               SCREEN_WIDTH / kLRLetterSectionCapacity
#define kDistanceBetweenSlots                           SCREEN_WIDTH / kLRLetterSectionCapacity


#define IS_IPHONE_5                 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_RETINA                   ([[UIScreen mainScreen] scale] == 2.0f)

#define SCREEN_HEIGHT                ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH                 ([[UIScreen mainScreen] bounds].size.width)

#define GAME_STATE_GAME_OVER                        @"Game over"
#define GAME_STATE_NEW_GAME                         @"New game"
#define GAME_STATE_PAUSE_GAME                       @"Game paused"
#define GAME_STATE_CONTINUE_GAME                    @"Game continued"
#define GAME_STATE_INCREASED_LEVEL                  @"Next level reached"
