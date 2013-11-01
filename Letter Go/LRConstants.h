//
//  LRConstants.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#define IS_IPHONE_5                 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_RETINA                   ([[UIScreen mainScreen] scale] == 2.0f)

#define SCREEN_WIDTH                ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT               ([[UIScreen mainScreen] bounds].size.width)

#define NAME_SPRITE_FALLING_ENVELOPE                @"NAME_SPRITE_FALLING_ENVELOPE"
#define NAME_SPRITE_SECTION_LETTER_BLOCK            @"NAME_SPRITE_SECTION_LETTER_BLOCK"
#define NAME_SPRITE_BOTTOM_EDGE                     @"NAME_SPRITE_BOTTOM_EDGE"
#define NAME_SPRITE_LETTER_SLOT                     @"NAME_SPRITE_LETTER_SLOT"

#define NAME_LAYER_GAME_PLAY                        @"NAME_LAYER_GAME_PLAY"
#define NAME_LAYER_BACKGROUND                       @"NAME_LAYER_BACKGROUND"

#define NOTIFICATION_ADDED_LETTER                   @"Added letter to slot"
#define NOTIFICATION_LETTER_CLEARED                 @"Letter has been removed from game play area"
#define NOTIFICATION_DELETE_LETTER                  @"Deleted a letter"
#define NOTIFICATION_SUBMIT_WORD                    @"Submit a word"
#define NOTIFICATION_REARRANGE_START                @"Started rearranging letters"
#define NOTIFICATION_REARRANGE_FINISH               @"Finished rearranging letters"

#define ACTION_DROP_ENVELOPE                        @"Droping the envelope"

#define GAME_STATE_GAME_OVER                        @"Game over"
#define GAME_STATE_NEW_GAME                         @"New game"

#define KEY_GET_LETTER                              @"Get letter"
#define KEY_GET_LETTER_BLOCK                        @"Get the letter block"

#define SIZE_HEIGHT_LETTER_SECTION                  (178 - 51)/2
#define SIZE_HEIGHT_HEALTH_SECTION                  7

#define LETTER_CAPACITY             7
#define LETTER_BLOCK_SIZE           48
