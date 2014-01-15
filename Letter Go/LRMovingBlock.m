//
//  LRMovingBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMovingBlock.h"

@interface LRMovingBlock ()
@property BOOL initialTouchInside;
@end

@implementation LRMovingBlock

#pragma mark - Initialization/Setters -

+ (LRMovingBlock*) movingBlockWithLetter:(NSString*)letter loveLetter:(BOOL)love
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

- (void) setSlot:(NSUInteger)slot
{
    _slot = slot;
    CGFloat topBufferSize = kSectionHeightHealth + kLetterBlockDimension/2;
    CGFloat bottomBufferSize = kSectionHeightLetterSection + kLetterBlockDimension/2;
    CGFloat letterDistance = (SCREEN_HEIGHT - topBufferSize - bottomBufferSize) /(kNumberOfSlots - 1);

    CGFloat xPos = SCREEN_WIDTH/2 + kLetterBlockDimension;
    CGFloat yPos = -SCREEN_HEIGHT/2 + bottomBufferSize + letterDistance * slot;
    self.position = CGPointMake(xPos, yPos);
}

#pragma mark - Touch Functions + Helpers
#pragma mark -

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location))
        {
            self.initialTouchInside = YES;
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.initialTouchInside)
        [self.touchDelegate playerSelectedMovingBlock:self];
}

#pragma mark - User Info Dictionary Functions
///TODO: remove this function
- (NSDictionary*) removeLetterDictionary
{
    NSDictionary *dict = [NSMutableDictionary dictionaryWithObject:self forKey:@"envelope"];
    return dict;
}

///TODO: remove this function
- (NSDictionary*) addLetterDictionary
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[self.letter, [NSNumber numberWithBool:self.loveLetter]]
                                                     forKeys:@[KEY_GET_LETTER, KEY_GET_LOVE]];
    return dict;
}
@end
