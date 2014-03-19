//
//  LRMovingBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMovingBlock.h"

static CGFloat const kFLKMovingBlockBetweenEnvelopeOffset = 11.0;
static CGFloat const kFLKMovingBlockBottomOffset = 3.0;

@interface LRMovingBlock ()
@property BOOL initialTouchInside;
@end

@implementation LRMovingBlock

#pragma mark - Initialization/Setters -

+ (LRMovingBlock *)movingBlockWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    return [[LRMovingBlock alloc] initWithLetter:letter loveLetter:love];
}

- (id) initWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    if (self = [super initWithLetter:letter loveLetter:love])
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
    
    CGFloat lowestPosition = (kLetterBlockDimension - kSectionHeightMainSection)/2;
    CGFloat betweenEnvelopeBuffer = kFLKMovingBlockBetweenEnvelopeOffset + kLetterBlockDimension;
    CGFloat xPos = SCREEN_WIDTH/2 + kLetterBlockDimension;
    CGFloat yPos = lowestPosition + kFLKMovingBlockBottomOffset + betweenEnvelopeBuffer * slot;
    
    return CGPointMake(xPos, yPos);
}

#pragma mark - Touch Functions + Helpers
#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
     Consider the letter touched if the player initially touches inside the letter.
     It is still considered a touch if the end of the touch is outside the letter
     */
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location))
        {
            self.initialTouchInside = YES;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //If the eltter is touched, go to the delegate
    if (self.initialTouchInside)
        [self.touchDelegate playerSelectedMovingBlock:self];
}

@end
