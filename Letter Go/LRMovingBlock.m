//
//  LRMovingBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMovingBlock.h"

static CGFloat const kLRMovingBlockBetweenEnvelopeOffset = 11.0;
static CGFloat const kLRMovingBlockBottomOffset = 3.0;

static CGFloat const kLRMovingBlockExtraTouchWidth = 70.0;
static CGFloat const kLRMovingBlockExtraTouchHeight = 4.0;

@interface LRMovingBlock ()
@end

@implementation LRMovingBlock

#pragma mark - Initialization/Setters -

+ (LRMovingBlock *)movingBlockWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    return [[LRMovingBlock alloc] initWithLetter:letter loveLetter:love];
}

- (id) initWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    CGSize touchSize = CGSizeMake(kLRMovingBlockExtraTouchWidth, kLRMovingBlockExtraTouchHeight);
    if (self = [super initWithLetter:letter loveLetter:love extraTouchSize:touchSize])
    {
        self.name = NAME_SPRITE_MOVING_ENVELOPE;
    }
    return self;
}

- (void)setSlot:(NSUInteger)slot
{
    _slot = slot;
    self.position = [LRMovingBlock positionForSlot:slot];
}

+ (CGPoint)positionForSlot:(NSUInteger)slot
{
    NSAssert(slot < kNumberOfSlots, @"Slot %i exceeds the proper number of slots", slot);
    
    CGFloat lowestPosition = (kLetterBlockSpriteDimension - kSectionHeightMainSection)/2;
    CGFloat betweenEnvelopeBuffer = kLRMovingBlockBetweenEnvelopeOffset + kLetterBlockSpriteDimension;
    CGFloat xPos = SCREEN_WIDTH/2 + kLetterBlockSpriteDimension;
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

@end
