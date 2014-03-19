//
//  LRLetterBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRGameStateDelegate.h"

@interface LRLetterBlock : SKSpriteNode <LRGameStateDelegate>

///The alphabetical letter represented by the envelope
@property (nonatomic, strong) NSString *letter;
///Whether or not the letter is a love letter
@property (nonatomic, readonly) BOOL loveLetter;

/*!
 @description Use this method to initialize a collected envelope
 @param letter The alphabetical letter
 @param loveLetter Whether or not the letter is a love letter
 @param extraTouchSize The additional size around the edges that the player can touch and have the envelope respond. For example, if this were {10, 5}, then the width of the touchable area would increase by 5 on either side and the height increased by 2.5 Initializes a letter block
 */
- (id) initWithLetter:(NSString *)letter loveLetter:(BOOL)love extraTouchSize:(CGSize)touchSize;

@end



