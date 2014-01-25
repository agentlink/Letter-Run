//
//  LRSectionBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/14/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRCollectedEnvelope.h"
#import "LRGameScene.h"
#import "LRLetterSlot.h"

@interface LRCollectedEnvelope ()
@property BOOL playerMovedTouch;
@end

@implementation LRCollectedEnvelope

#pragma mark - Set Up
+ (LRCollectedEnvelope*) sectionBlockWithLetter:(NSString*)letter loveLetter:(BOOL)love
{
    return [[LRCollectedEnvelope alloc] initWithLetter:letter loveLetter:love];
}

+ (LRCollectedEnvelope*) emptySectionBlock
{
    return [[LRCollectedEnvelope alloc] initWithLetter:@"" loveLetter:false];
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
    //Move the block from being the child of the letter slot to the child of the whole letter section
    LRLetterSection *letterSection = [[(LRGameScene*)[self scene] gamePlayLayer] letterSection];
    LRLetterSlot *parentSlot = (LRLetterSlot*)[self parent];
    CGPoint newPos = [self convertPoint:self.position toNode:letterSection];
    self.position = newPos;
    [parentSlot setEmptyLetterBlock];
    [letterSection addChild:self];

    [self.delegate rearrangementHasBegunWithLetterBlock:self];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        //Finish rearranging the letters
        [self.delegate rearrangementHasFinishedWithLetterBlock:self];

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
