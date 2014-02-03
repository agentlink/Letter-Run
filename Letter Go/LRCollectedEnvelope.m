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

typedef NS_ENUM(NSUInteger, MovementDirection)
{
    //Remove none if it doesn't get used
    MovementDirectionNone = 0,
    MovementDirectionHorizontal,
    MovementDirectionVertical
};


@interface LRCollectedEnvelope ()
@property MovementDirection movementDirection;
@property CGPoint touchOrigin;
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
        self.movementDirection = MovementDirectionNone;
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
            self.touchOrigin = location;
            self.movementDirection = MovementDirectionNone;

            //Get the movement direction...
            if (self.movementDirection == MovementDirectionHorizontal) {
            }
        }
    }
}

//Swipe function is done here by checking to see how far the player moved the block
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint touchLoc = [touch locationInNode:[self parent]];
        CGPoint envelopeLoc = self.position;
        
        //If the movement direction hasn't been set, calculate it
        if (self.movementDirection == MovementDirectionNone) {
            MovementDirection direction = [self movementDirectionFromPoint:self.touchOrigin toPoint:touchLoc];
            if (direction == MovementDirectionHorizontal) {
                [self releaseBlockForRearrangement];
                self.zPosition += 5;
            }
            else if (direction == MovementDirectionVertical){
                //vertical scroll release case
            }
            self.movementDirection = direction;
        }

        //Horizontal scroll case
        else if (self.movementDirection == MovementDirectionHorizontal) {
            self.position = CGPointMake(touchLoc.x, envelopeLoc.y);
        }
        //Vertical scroll case
        else {
            self.position = CGPointMake(envelopeLoc.x, touchLoc.y);
            //while (code == code)
                //code();
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        //If the scroll is horizontal, finish moving the letters
        if (self.movementDirection == MovementDirectionHorizontal) {
            [self.delegate rearrangementHasFinishedWithLetterBlock:self];
      //      self.zPosition -= 5;
        }
        else {
            if ([self shouldEnvelopeBeDeletedAtPosition:self.position])
            {
                [self.delegate removeEnvelopeFromLetterSection:self];
            }
            else {
                self.position = CGPointZero;
            }
        }
        self.movementDirection = MovementDirectionNone;
    }
}

#pragma mark - Touch Helper Functions

- (MovementDirection) movementDirectionFromPoint:(CGPoint)origin toPoint:(CGPoint)newLoc
{
    CGFloat xDiff = ABS(newLoc.x - origin.x);
    CGFloat yDiff = ABS(newLoc.y - origin.y);
    CGFloat scrollDetectionThreshold = 1.5;
    
    if (xDiff/yDiff > scrollDetectionThreshold)
        return MovementDirectionHorizontal;
    else if (yDiff/xDiff > scrollDetectionThreshold)
        return MovementDirectionVertical;
    return MovementDirectionNone;
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

- (BOOL) shouldEnvelopeBeDeletedAtPosition:(CGPoint)pos
{
    CGFloat currentYPos = pos.y;
    //#toy
    CGFloat topOffScreenRatioForDeletion = .6;
    CGFloat bottomOffScreenRatioForDeletion = .4;
    CGFloat maxY = self.size.height * topOffScreenRatioForDeletion;
    CGFloat minY = -self.size.height * bottomOffScreenRatioForDeletion;
    
    return (currentYPos > maxY || currentYPos < minY);

}

#pragma mark - Block State Checks

- (BOOL) isLetterBlockEmpty {
    return ![[self letter] length];
}

- (BOOL) isLetterBlockPlaceHolder {
    return ([self.letter isEqualToString:kLetterPlaceHolderText]);
}

@end
