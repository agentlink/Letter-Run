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
@property (nonatomic, strong) NSString *letter;
@property (readwrite) BOOL loveLetter;
@property (readwrite) BOOL isTouched;
@end

@implementation LRLetterBlock

#pragma mark - Initializers/Set Up

- (id) initWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    NSAssert(0, @"initWithLetter should be implemented by subclass");
    return nil;
}

- (id) initWithSize:(CGSize)size letter:(NSString *)letter loveLetter:(BOOL)love
{
    if (self = [super initWithColor:[LRColor clearColor] size:size])
    {
        self.letter = letter;
        self.loveLetter = love;
        self.envelopeSprite = [self _envelopeSpriteForLetter:letter loveLetter:love];
        if (self.envelopeSprite) {
            [self addChild:self.envelopeSprite];
        }
        self.userInteractionEnabled = YES;
    }
    return self;

}

- (void)setLetter:(NSString *)letter
{
    _letter = letter;
    if ([LRLetterBlock isLetterAlphabetical:letter]) {
        self.letterLabel.text = letter;
        [self addChild:self.letterLabel];
    }
}

- (void)setTouchSize:(CGSize)extraTouchSize
{
    CGSize envelopeSize = self.envelopeSprite.size;
    _touchSize = extraTouchSize;
    self.size = extraTouchSize;
    self.envelopeSprite.size = envelopeSize;
}


#pragma mark - Children Set Up

- (SKLabelNode *)letterLabel
{
    if (!_letterLabel) {
        LRFont *letterFont = [LRFont letterBlockFont];
        _letterLabel = [SKLabelNode new];
        _letterLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - (self.size.height - self.touchSize.height)/4);
        _letterLabel.color = [LRColor debugColor1];
        _letterLabel.fontSize = letterFont.pointSize;
        _letterLabel.fontName = letterFont.fontName;
        _letterLabel.fontColor = [LRColor letterBlockFontColor];
        _letterLabel.zPosition += zDiff_Letter_Envelope;
    }
    return _letterLabel;
}

- (SKSpriteNode *)_envelopeSpriteForLetter:(NSString *)letter loveLetter:(BOOL)love
{
    BOOL placeholderBlock = [LRLetterBlock isLetterPlaceholder:letter];
    SKSpriteNode *envelopeSprite;
    NSString *fileName = nil;
    if ([LRLetterBlock isLetterAlphabetical:letter]) {
        fileName = (love) ? @"envelope-love" : @"envelope-normal" ;
    }
    else if (placeholderBlock) {
        fileName = @"envelope-glow";
    }
    if (fileName) {
        envelopeSprite = [SKSpriteNode spriteNodeWithImageNamed:fileName];
        envelopeSprite.size = CGSizeMake(self.size.width - self.touchSize.width,
                                         self.size.height - self.touchSize.height);
        if (placeholderBlock) {
            envelopeSprite.alpha = .2;
        }
    }

    return envelopeSprite;
}

#pragma mark - Touch Functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouched = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouched = NO;
}

#pragma mark - Helper Functions
///Checks if the letter is not a placeholder or empty

+ (BOOL)isLetterAlphabetical:(NSString *)letter
{
    if (![letter length] || [letter isEqualToString:kLetterPlaceHolderText])
        return NO;
    return YES;
}

+ (BOOL)isLetterPlaceholder:(NSString *)letter
{
    return [letter isEqualToString:kLetterPlaceHolderText];
}
@end
