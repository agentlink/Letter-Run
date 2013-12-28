//
//  LRLetterBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"
#import "LRCollisionManager.h"
#import "LRGameScene.h"
#import "LRGameStateManager.h"
#import "LRLetterSlot.h"
#import "LRPositionConstants.h"

@interface LRLetterBlock ()

@property (nonatomic, strong) SKSpriteNode *envelopeSprite;
@property (nonatomic, strong) SKLabelNode *letterLabel;
@property (readwrite) BOOL loveLetter;

@end

@implementation LRLetterBlock

#pragma mark - Initializers/Set Up
+ (LRLetterBlock*) letterBlockWithLetter:(NSString*)letter loveLetter:(BOOL)love;
{
    return [[LRLetterBlock alloc] initWithLetter:letter loveLetter:love];
}

- (id) initWithLetter:(NSString*)letter loveLetter:(BOOL)love
{
    if (self = [super initWithColor:[LRColor clearColor] size:CGSizeMake(SIZE_LETTER_BLOCK, SIZE_LETTER_BLOCK)]) {
        self.letter = letter;
        self.loveLetter = love;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) setLetter:(NSString *)letter
{
    _letter = letter;
    if ([self isLetterAlphabetical]) {
        self.letterLabel.text = letter;
        [self addChild:self.letterLabel];
    }
}

- (void) setLoveLetter:(BOOL)loveLetter
{
    _loveLetter = loveLetter;
    if ([self isLetterAlphabetical]) {
        [self addChild:self.envelopeSprite];
    }
}

#pragma mark - Children Set Up

- (SKLabelNode*) letterLabel
{
    if (!_letterLabel) {
        UIFont *letterFont = [LRFont letterBlockFont];
        _letterLabel = [SKLabelNode new];
        _letterLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - SIZE_LETTER_BLOCK/4);
        _letterLabel.fontSize = letterFont.pointSize;
        _letterLabel.fontName = letterFont.fontName;
        _letterLabel.fontColor = [LRColor letterBlockFontColor];
        _letterLabel.zPosition += zDiff_Letter_Envelope;
    }
    return _letterLabel;
}

- (SKSpriteNode*) envelopeSprite
{
    if (!_envelopeSprite) {
        NSString *fileName = [self fileNameForEnvelopeSprite];
        _envelopeSprite = [SKSpriteNode spriteNodeWithImageNamed:fileName];
        _envelopeSprite.xScale = SIZE_LETTER_BLOCK/self.envelopeSprite.size.width;
        _envelopeSprite.yScale = SIZE_LETTER_BLOCK/self.envelopeSprite.size.height;
    }
    return _envelopeSprite;
}


#pragma mark - Helper Functions

- (NSString*) fileNameForEnvelopeSprite
{
    NSString *fileName = (self.loveLetter) ? @"Envelope_Love.png" : @"Envelope_Normal.png";
    return fileName;
}

///Checks if the letter is not a placeholder or empty
- (BOOL) isLetterAlphabetical
{
    if (![self.letter length] || [self.letter isEqualToString:LETTER_PLACEHOLDER_TEXT])
        return NO;
    return YES;
}

@end
