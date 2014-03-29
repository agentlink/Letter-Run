//
//  LRConstants.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//


//TODO: Clean this page up, good lord

typedef NS_ENUM(BOOL, kLRDirection)
{
    //Remove none if it doesn't get used
    kLeftDirection = FALSE,
    kRightDirection
};

//Size constants
static const float kSectionHeightButtonSection  =       55;
static const float kSectionHeightLetterSection  =       63;
static const float kSectionHeightHealthSection         =       18.0;

#define kSectionHeightMainSection           (SCREEN_HEIGHT - kSectionHeightLetterSection - kSectionHeightHealthSection - kSectionHeightButtonSection)
static const float kCollectedEnvelopeSpriteDimension  =       40.0;
static const float kMovingEnvelopeSpriteDimension     =       60.0;
static const float kParallaxHeightGrass               =       26.6;
#define kDistanceBetweenSlots                           SCREEN_WIDTH / kWordMaximumLetterCount
#define kDistanceBetweenSlotAndEdge                     66 * SCREEN_WIDTH/960.0

//Letter constants
static const int kWordMinimumLetterCount        =       3;
static const int kWordMaximumLetterCount        =       7;
static const int kNumberOfSlots                 =       4;
static NSString* const kLetterPlaceHolderText   =       @" ";


//Timing constants
static const int kGameLoopResetValue            =       -1;

#define IS_IPHONE_5                 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_RETINA                   ([[UIScreen mainScreen] scale] == 2.0f)

#define SCREEN_HEIGHT                ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH                 ([[UIScreen mainScreen] bounds].size.width)

#define NAME_SPRITE_FALLING_ENVELOPE                @"NAME_SPRITE_FALLING_ENVELOPE"
#define NAME_SPRITE_MOVING_ENVELOPE                 @"NAME_SPRITE_MOVING_ENVELOPE"
#define NAME_SPRITE_SECTION_LETTER_BLOCK            @"NAME_SPRITE_SECTION_LETTER_BLOCK"
#define NAME_SPRITE_BOTTOM_EDGE                     @"NAME_SPRITE_BOTTOM_EDGE"
#define NAME_SPRITE_LETTER_SLOT                     @"NAME_SPRITE_LETTER_SLOT"
#define NAME_SPRITE_MAILMAN                         @"NAME_SPRITE_MAILMAN"
#define NAME_SPRITE_BOTTOM_BARRIER                  @"NAME_SPRITE_BOTTOM_BARRIER"


#define NAME_LAYER_GAME_PLAY                        @"NAME_LAYER_GAME_PLAY"
#define NAME_LAYER_BACKGROUND                       @"NAME_LAYER_BACKGROUND"

#define NOTIFICATION_SUBMIT_WORD                    @"Submit a word"
#define NOTIFICATION_ENVELOPE_HIT_MAILMAN           @"Envelope hit the mailman"
#define NOTIFICATION_REARRANGE_START                @"Started rearranging letters"
#define NOTIFICATION_REARRANGE_FINISH               @"Finished rearranging letters"
#define NOTIFICATION_RESET_DIFFICULTIES             @"Reset difficulty values"

#define ACTION_REARRANGE_SWITCH                     @"Rearrange action shift to block "

#define GAME_STATE_GAME_OVER                        @"Game over"
#define GAME_STATE_NEW_GAME                         @"New game"
#define GAME_STATE_PAUSE_GAME                       @"Game paused"
#define GAME_STATE_CONTINUE_GAME                    @"Game continued"

#define KEY_GET_LETTER                              @"Get letter"
#define KEY_GET_LETTER_BLOCK                        @"Get the letter block"
#define KEY_GET_LOVE                                @"Get whether it's a love letter"

