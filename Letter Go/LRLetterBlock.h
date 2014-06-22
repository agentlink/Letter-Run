//
//  LRLetterBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRGameStateDelegate.h"

static NSString * const kLetterBlockEmptyLetter  = @"";
static NSString * const kLetterBlockHolderText   = @" ";

static NSInteger const kNumPaperColors = 3;

@interface LRLetterBlock : SKSpriteNode <LRGameStateDelegate>

typedef NS_ENUM(NSInteger, LRPaperColor)
{
    kLRPaperColorNone = -1,
    kLRPaperColorYellow = 0,
    kLRPaperColorBlue,
    kLRPaperColorPink,
};

///The additional size around the edges that the player can touch and have the envelope respond. For example, if this were {10, 5}, then the width of the touchable area would increase by 5 on either side and the height increased by 2.5 Initializes a letter block
@property (nonatomic, readwrite) CGSize touchSize;
///The alphabetical letter represented by the envelope
@property (nonatomic, readwrite) NSString *letter;
///The label containing the letter
@property (nonatomic, strong) SKLabelNode *letterLabel;
///Returns TRUE if the letter is currently being touched
@property (nonatomic, readonly) BOOL isTouched;
///The paper color of letter or envelope. Correlates with both the envelope's score value and sprite color
@property (nonatomic) LRPaperColor paperColor;
///The sprite of the envelope
@property (nonatomic, strong) SKSpriteNode *envelopeSprite;

/*!
 @description Use this method to initialize a collected envelope
 @param size The size of the envelope as it appears on the screen

@param paper The paper color and thus score value that the letter
@param letter The alphabetical letter
 */
- (id) initWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor size:(CGSize)size;
- (id) initWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor;

#pragma Helper Functions

///Returns YES if the letter is not a placeholder or and empty block
+ (BOOL)isLetterAlphabetical:(NSString *)letter;
///Returns yes if the letter is a placeholder
+ (BOOL)isLetterPlaceholder:(NSString *)letter;
///Returns the name of the paper color (e.g. "yellow", "pink", etc)
+ (NSString *)stringValueForPaperColor:(LRPaperColor)paperColor;
///Returns the paper color for the name of a string
+ (LRPaperColor)paperColorForString:(NSString *)string;

@end



