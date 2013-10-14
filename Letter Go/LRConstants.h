//
//  LRConstants.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#define IS_IPHONE_5                 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_RETINA                   ([[UIScreen mainScreen] scale] == 2.0f)

#define NAME_FALLING_ENVELOPE               @"Falling letter block"
#define NAME_SECTION_LETTER_BLOCK           @"Letter block in letter section"
#define NAME_BOTTOM_EDGE                    @"Bottom edge where blocks land"
#define NAME_LETTER_SLOT                    @"Letter slot"

#define NOTIFICATION_ADDED_LETTER           @"Added letter to slot"
#define NOTIFICATION_DROP_LETTER            @"Drop a new letter"
#define NOTIFICATION_DELETE_LETTER          @"Deleted a letter"
#define NOTIFICATION_SUBMIT_WORD            @"Submit a word"
#define NOTIFICATION_REARRANGE_START        @"Started rearranging letters"
#define NOTIFICATION_REARRANGE_FINISH       @"Finished rearranging letters"

#define KEY_GET_LETTER                      @"Get letter"
#define KEY_GET_LETTER_BLOCK                @"Get the letter block"

#define LETTER_CAPACITY             7
#define LETTER_BLOCK_SIZE           48

typedef enum {
    HorDirectionLeft,
    HorDirectionRight
} HorDirection;