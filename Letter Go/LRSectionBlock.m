//
//  LRSectionBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/14/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRSectionBlock.h"
#import "LRGameScene.h"
#import "LRLetterSlot.h"

@interface LRSectionBlock ()
@property BOOL playerMovedTouch;
@end

@implementation LRSectionBlock

#pragma mark - Set Up
+ (LRSectionBlock*) sectionBlockWithLetter:(NSString*)letter loveLetter:(BOOL)love
{
    return [[LRSectionBlock alloc] initWithLetter:letter loveLetter:love];
}

+ (LRSectionBlock*) emptySectionBlock
{
    return [[LRSectionBlock alloc] initWithLetter:@"" loveLetter:false];
}

- (id) initWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    if (self = [super initWithLetter:letter loveLetter:love]) {
        self.name = NAME_SPRITE_SECTION_LETTER_BLOCK;
    }
    return self;
}

#pragma mark - Touch Functions
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location))
        {
            self.playerMovedTouch = FALSE;
            [self releaseBlockForRearrangement];
            self.zPosition += 5;
        }
    }
}

//Swipe function is done here by checking to see how far the player moved the block
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        self.playerMovedTouch = TRUE;
        CGPoint location = [touch locationInNode:[self parent]];
        self.position = CGPointMake(location.x, self.position.y);
    }
}

- (void) releaseBlockForRearrangement
{
    LRLetterSection *letterSection = [[(LRGameScene*)[self scene] gamePlayLayer] letterSection];
    LRLetterSlot *parentSlot = (LRLetterSlot*)[self parent];
    CGPoint newPos = [self convertPoint:self.position toNode:letterSection];
    self.position = newPos;
    [parentSlot setEmptyLetterBlock];
    [letterSection addChild:self];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REARRANGE_START object:self userInfo:[NSDictionary dictionaryWithObject:self forKey:@"block"]];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        //Finish rearranging the letters
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REARRANGE_FINISH object:self userInfo:[NSDictionary dictionaryWithObject:self forKey:@"block"]];

        //If the player didn't move the block, delete it
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location) && !self.playerMovedTouch)
        {
            [self.delegate removeEnvelopeFromLetterSection:self];
        }
        self.zPosition -= 5;
        self.playerMovedTouch = FALSE;
    }
}


#pragma mark - Block State Checks

- (BOOL) isLetterBlockEmpty {
    return ![[self letter] length];
}

- (BOOL) isLetterBlockPlaceHolder {
    return ([self.letter isEqualToString:LETTER_PLACEHOLDER_TEXT]);
}

@end
