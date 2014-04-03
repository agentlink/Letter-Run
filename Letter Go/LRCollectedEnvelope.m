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
#import "LRCollisionManager.h"
#import "LREnvelopeAnimationBuilder.h"

typedef NS_ENUM(NSUInteger, MovementDirection)
{
    //Remove none if it doesn't get used
    MovementDirectionNone = 0,
    MovementDirectionHorizontal,
    MovementDirectionVertical
};


@interface LRCollectedEnvelope ()
@end

@implementation LRCollectedEnvelope

#pragma mark - Set Up
+ (LRCollectedEnvelope *)collectedEnvelopeWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    return [[LRCollectedEnvelope alloc] initWithLetter:letter loveLetter:love];
}

+ (LRCollectedEnvelope *)emptyCollectedEnvelope
{
    return [[LRCollectedEnvelope alloc] initWithLetter:@"" loveLetter:NO];
}

+ (LRCollectedEnvelope *)placeholderCollectedEnvelope
{
    return [[LRCollectedEnvelope alloc] initWithLetter:kLetterPlaceHolderText loveLetter:NO];
}

- (id) initWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    CGSize size = CGSizeMake(kCollectedEnvelopeSpriteDimension, kCollectedEnvelopeSpriteDimension);
    if (self = [super initWithSize:size letter:letter loveLetter:love]) {
        self.name = NAME_SPRITE_SECTION_LETTER_BLOCK;
        self.slotIndex = kSlotIndexNone;
    }
    return self;
}

#pragma mark - Touch Functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location))
        {
            [self releaseBlockForRearrangement];
            SKAction *bubble = [LREnvelopeAnimationBuilder bubbleByScale:kLRCollectedEnvelopeBubbleScale
                                                            withDuration:kLRCollectedEnvelopeBubbleDuration];
            [self runAction:bubble];
        }
    }
}

//Swipe function is done here by checking to see how far the player moved the block
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint touchLoc = [touch locationInNode:[self parent]];
        self.position = touchLoc;
        BOOL canDelete = [self shouldEnvelopeBeDeletedAtPosition:self.position];
        if (canDelete != self.isAtDeletionPoint) {
            self.isAtDeletionPoint = canDelete;
            SKAction *animation = [LREnvelopeAnimationBuilder changeEnvelopeCanDeleteState:canDelete];
            [self runAction:animation];
        }
//        self.alpha = ([self shouldEnvelopeBeDeletedAtPosition:self.position]) ? .5 : 1.0;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event

{
    if ([self shouldEnvelopeBeDeletedAtPosition:self.position])
    {
        [self.delegate removeEnvelopeFromLetterSection:self];
    }
    else {
        [self.delegate rearrangementHasFinishedWithLetterBlock:self];
        SKAction *returnToSlot = [SKAction moveTo:CGPointZero duration:1];
        SKAction *bubble = [LREnvelopeAnimationBuilder bubbleByScale:1/kLRCollectedEnvelopeBubbleScale
                                                    withDuration:kLRCollectedEnvelopeBubbleDuration];
        SKAction *bubbleAndReturn = [SKAction group:@[returnToSlot, bubble]];
        [self runAction:bubbleAndReturn];
        
    }
}

#pragma mark - Touch Helper Functions

- (void)releaseBlockForRearrangement
{
    //Move the block from being the child of the letter slot to the child of the whole letter section
    LRLetterSection *letterSection = [[(LRGameScene *)[self scene] gamePlayLayer] letterSection];
    LRLetterSlot *parentSlot = (LRLetterSlot *)[self parent];
    self.position = parentSlot.position;
    [parentSlot setEmptyLetterBlock];
    [letterSection addChild:self];

    [self.delegate rearrangementHasBegunWithLetterBlock:self];
}

- (BOOL) shouldEnvelopeBeDeletedAtPosition:(CGPoint)pos
{
    CGFloat currentYPos = pos.y;
    //#toy
    if ((currentYPos > (kSectionHeightLetterSection + kCollectedEnvelopeSpriteDimension)/2) ||
         currentYPos < -kCollectedEnvelopeSpriteDimension) {
        return YES;
    }
    return NO;

}

- (NSString *)description
{
    NSMutableString * descript = [[super description] mutableCopy];
    [descript appendFormat:@"Letter: %@", self.letter];
    return descript;
}

#pragma mark - Block State Checks

- (BOOL) isCollectedEnvelopeEmpty {
    return ![[self letter] length];
}

- (BOOL) isCollectedEnvelopePlaceholder {
    return ([self.letter isEqualToString:kLetterPlaceHolderText]);
}

@end
