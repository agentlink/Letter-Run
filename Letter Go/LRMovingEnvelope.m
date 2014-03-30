//
//  LRMovingBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMovingEnvelope.h"
#import "LREnvelopeAnimationBuilder.h"

static CGFloat const kLRMovingBlockBetweenEnvelopeOffset = 94.5;
static CGFloat const kLRMovingBlockBottomOffset = 3.0;
static CGFloat const kLRMovingBlockTouchSizeExtraWidth = 25.0;
static CGFloat const kLRMovingBlockTouchSizeExtraHeight = 35.0;

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
    CGSize size = CGSizeMake(kMovingEnvelopeSpriteDimension, kMovingEnvelopeSpriteDimension);
    if (self = [super initWithSize:size letter:letter loveLetter:love])
    {
        self.name = NAME_SPRITE_MOVING_ENVELOPE;
        [self _setGlowEnabled:NO];
        [self addChild:self.glow];
        
        CGSize touchSize = self.size;
        touchSize.width += kLRMovingBlockTouchSizeExtraWidth;
        touchSize.height += kLRMovingBlockTouchSizeExtraHeight;
        self.touchSize = touchSize;
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
    CGFloat xPos = SCREEN_WIDTH/2 + kMovingEnvelopeSpriteDimension;
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
    CGFloat bubbleScale = selected ? kLRCollectedEnvelopeBubbleScale : 1/kLRCollectedEnvelopeBubbleScale;
    SKAction *bubbleAction = [LREnvelopeAnimationBuilder bubbleByScale:bubbleScale
                                                          withDuration:kLRCollectedEnvelopeBubbleDuration];
    [self runAction:bubbleAction];


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
