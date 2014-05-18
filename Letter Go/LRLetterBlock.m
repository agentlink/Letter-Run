//
//  LRLetterBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"
#import "LRGameScene.h"
#import "LRGameStateManager.h"
#import "LRLetterSlot.h"
#import "LRPositionConstants.h"

@interface LRLetterBlock ()

@property (readwrite) BOOL isTouched;
@end

@implementation LRLetterBlock

#pragma mark - Initializers/Set Up

- (id) initWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor
{
    NSAssert(0, @"initWithLetter should be implemented by subclass");
    return nil;
}

- (id) initWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor size:(CGSize)size
{
    if (self = [super initWithColor:[LRColor clearColor] size:size])
    {
        self.paperColor = paperColor;
        self.letter = letter;
        self.userInteractionEnabled = YES;
        [self addChild:self.letterLabel];
    }
    return self;

}
- (void)setLetter:(NSString *)letter
{
    _letter = letter;
    if ([LRLetterBlock isLetterAlphabetical:letter]) {
        self.letterLabel.text = letter;
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

#pragma mark - Touch Functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouched = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouched = NO;
}

///Checks if the letter is not a placeholder or empty
+ (BOOL)isLetterAlphabetical:(NSString *)letter
{
    if (![letter length] || [letter isEqualToString:kLetterBlockHolderText])
        return NO;
    return YES;
}

+ (BOOL)isLetterPlaceholder:(NSString *)letter
{
    return [letter isEqualToString:kLetterBlockHolderText];
}
@end
