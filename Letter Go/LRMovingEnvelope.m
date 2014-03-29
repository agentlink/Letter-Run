//
//  LRMovingBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMovingEnvelope.h"

static CGFloat const kLRMovingBlockBetweenEnvelopeOffset = 94.5;
static CGFloat const kLRMovingBlockBottomOffset = 3.0;

static CGFloat const kLRMovingBlockExtraTouchWidth = 70.0;
static CGFloat const kLRMovingBlockExtraTouchHeight = 4.0;

#define kLRMovingBlockLowestPoint  (-kSectionHeightMainSection/2) + 42

@interface LRMovingEnvelope ()
@property (nonatomic, strong) SKSpriteNode *glow;
@end

@implementation LRMovingEnvelope

#pragma mark - Initialization/Setters -

+ (LRMovingEnvelope *)movingBlockWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    return [[LRMovingEnvelope alloc] initWithLetter:letter loveLetter:love];
}

- (id) initWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    CGSize envelopeSize = CGSizeMake(kMovingEnvelopeLetterBlockSpriteDimension, kMovingEnvelopeLetterBlockSpriteDimension);
    CGSize touchSize = CGSizeMake(kLRMovingBlockExtraTouchWidth, kLRMovingBlockExtraTouchHeight);
    if (self = [super initWithSize:envelopeSize letter:letter loveLetter:love extraTouchSize:touchSize])
    {
        self.name = NAME_SPRITE_MOVING_ENVELOPE;
        [self _setGlowEnabled:NO];
        [self addChild:self.glow];
        
    }
    return self;
}

- (SKSpriteNode *)glow {
    if (!_glow) {
        _glow = [SKSpriteNode spriteNodeWithImageNamed:@"envelope-glow"];
        _glow.zPosition = -1;
        _glow.alpha = 0.0;
    }
    return _glow;
}

- (void)setSlot:(NSUInteger)slot
{
    _slot = slot;
    self.position = [LRMovingEnvelope positionForSlot:slot];
}

+ (CGPoint)positionForSlot:(NSUInteger)slot
{
    NSAssert(slot < kNumberOfSlots, @"Slot %i exceeds the proper number of slots", slot);
    
    CGFloat lowestPosition = kLRMovingBlockLowestPoint;
    CGFloat betweenEnvelopeBuffer = kLRMovingBlockBetweenEnvelopeOffset;
    CGFloat xPos = SCREEN_WIDTH/2 + kMovingEnvelopeLetterBlockSpriteDimension;
    CGFloat yPos = lowestPosition + kLRMovingBlockBottomOffset + betweenEnvelopeBuffer * slot;
    
    return CGPointMake(xPos, yPos);
}

#pragma mark - Touch Functions + Helpers
#pragma mark -

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //If the eltter is touched, go to the delegate
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location)) {
            [self.touchDelegate playerSelectedMovingBlock:self];
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self _setGlowEnabled:selected];
}

- (void)_setGlowEnabled:(BOOL)enabled
{
    CGFloat fadedAlpha = 0.7;
    CGFloat fadeDuration = 0.15;

    CGFloat newEnvelopeAlpha = (enabled) ? fadedAlpha : 1.0;
    CGFloat newGlowAlpha = (enabled) ? fadedAlpha : 0.0;

    SKAction *fadeEnvelope = [SKAction fadeAlphaTo:newEnvelopeAlpha duration:fadeDuration];
    SKAction *fadeGlow = [SKAction fadeAlphaTo:newGlowAlpha duration:fadeDuration];
    [self runAction:fadeEnvelope];
    [self.glow runAction:fadeGlow];
    
}

@end
