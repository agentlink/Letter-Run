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
#define NAME_SPRITE_MAILMAN                         @"NAME_SPRITE_MAILMAN"

#define NAME_LAYER_GAME_PLAY                        @"NAME_LAYER_GAME_PLAY"
#define NAME_LAYER_BACKGROUND                       @"NAME_LAYER_BACKGROUND"

#define NOTIFICATION_ADDED_LETTER                   @"Added letter to slot"
#define NOTIFICATION_LETTER_CLEARED                 @"Letter has been removed from game play area"
#define NOTIFICATION_DELETE_LETTER                  @"Deleted a letter"
#define NOTIFICATION_SUBMIT_WORD                    @"Submit a word"

#define NOTIFICATION_ENVELOPE_LANDED                @"Envelope hit the ground"
#define NOTIFICATION_ENVELOPE_HIT_MAILMAN           @"Envelope hit the mailman"

#define NOTIFICATION_REARRANGE_START                @"Started rearranging letters"
#define NOTIFICATION_REARRANGE_FINISH               @"Finished rearranging letters"

#define NOTIFICATION_RESET_DIFFICULTIES             @"Reset difficulty values"

#define ACTION_ENVELOPE_DROP                        @"DropPing the envelope"
#define ACTION_ENVELOPE_LOOP                        @"Run envelope loop"
#define ACTION_ENVELOPE_FLING                       @"Fling the envelope"

#define GAME_STATE_GAME_OVER                        @"Game over"
#define GAME_STATE_NEW_GAME                         @"New game"
#define GAME_STATE_PAUSE_GAME                       @"Game paused"
#define GAME_STATE_CONTINUE_GAME                    @"Game continued"

#define KEY_GET_LETTER                              @"Get letter"
#define KEY_GET_LETTER_BLOCK                        @"Get the letter block"
#define KEY_GET_LOVE                                @"Get whether it's a love letter"

#define SIZE_HEIGHT_LETTER_SECTION                  (178 - 51)/2
#define SIZE_HEIGHT_HEALTH_SECTION                  7

#define LETTER_CAPACITY             7
#define LETTER_BLOCK_SIZE           48
