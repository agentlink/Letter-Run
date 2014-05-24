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
#import "LREnvelopeAnimationBuilder.h"
#import "LRLetterSlot.h"
#import "LRGameStateManager.h"
#import "LRSharedTextureCache.h"

static CGFloat const kLRCollectedEnvelopeBubbleScale = 1.28;
static CGFloat const kLRCollectedEnvelopeBubbleDuration = .12;

NSString * const kLRCollectedEnvelopeTemporaryName = @"Collected envelope TEMPORARY";
NSString * const kLRCollectedEnvelopeName = @"Collected envelope";

typedef NS_ENUM(NSUInteger, MovementDirection)
{
    //Remove none if it doesn't get used
    MovementDirectionNone = 0,
    MovementDirectionHorizontal,
    MovementDirectionVertical
};


@interface LRCollectedEnvelope ()
@property (nonatomic, strong) SKSpriteNode *envelopeSprite;
@property (nonatomic, readwrite, weak) LRLetterSlot *parentSlot;
@property (nonatomic) BOOL touchedAfterGameOver;
@end

@implementation LRCollectedEnvelope

#pragma mark - Public Functions

+ (LRCollectedEnvelope *)collectedEnvelopeWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor
{
    return [[LRCollectedEnvelope alloc] initWithLetter:letter paperColor:paperColor];
}

+ (LRCollectedEnvelope *)emptyCollectedEnvelope
{
    return [[LRCollectedEnvelope alloc] initWithLetter:@"" paperColor:kLRPaperColorNone];
}

+ (LRCollectedEnvelope *)placeholderCollectedEnvelope
{
    return [[LRCollectedEnvelope alloc] initWithLetter:kLetterBlockHolderText paperColor:kLRPaperColorNone];
}

#pragma mark - Helper Functions

- (NSString *)stringFromPaperColor:(LRPaperColor)paperColor
{
    switch (paperColor) {
        case kLRPaperColorBlue:
            return @"paper-blue";
            break;
        case kLRPaperColorPink:
            return @"paper-pink";
            break;
        case kLRPaperColorYellow:
            return @"paper-yellow";
            break;
        case kLRPaperColorNone:
            return nil;
            break;
    }
}

- (LRCollectedEnvelope *)animatableCopyOfEnvelope
{
    LRCollectedEnvelope *animatableEnvelopeCopy = [self copy];
    animatableEnvelopeCopy.name = kLRCollectedEnvelopeTemporaryName;
    animatableEnvelopeCopy.userInteractionEnabled = NO;
    return animatableEnvelopeCopy;
}

- (id)initWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor
{
    CGSize size = CGSizeMake(kCollectedEnvelopeSpriteDimension, kCollectedEnvelopeSpriteDimension);
    if (self = [super initWithLetter:letter paperColor:paperColor size:size]) {
        self.slotIndex = kSlotIndexNone;
        NSString *imageName = [self stringFromPaperColor:paperColor];
        if (imageName) {
            SKTexture *envelopeTexture = [[LRSharedTextureCache shared] textureForName:imageName];
            self.envelopeSprite = [SKSpriteNode spriteNodeWithTexture:envelopeTexture];
            [self addChild:self.envelopeSprite];
        }
    }
    return self;
}

- (LRLetterSlot *)parentSlot
{
    if ([[self parent] isKindOfClass:[LRLetterSlot class]]) {
        return (LRLetterSlot *)[self parent];
    }
    return nil;
}

#pragma mark - Touch Functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self.parent];
        if (CGRectContainsPoint(self.frame, location))
        {
            self.position = location;
            [self releaseBlockForRearrangement];
            SKAction *expand = [LREnvelopeAnimationBuilder animateToScale:kLRCollectedEnvelopeBubbleScale withDuration:kLRCollectedEnvelopeBubbleDuration];
            [self runAction:expand];
        }
    }
}

//Swipe function is done here by checking to see how far the player moved the block
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.touchedAfterGameOver) {
        return;
    }
    
    NSString *kRotateActionName = @"kRotateActionName";
    for (UITouch *touch in touches)
    {
        BOOL canDelete = [self shouldEnvelopeBeDeletedAtPosition:self.position];
        if (canDelete != self.isAtDeletionPoint) {
            self.isAtDeletionPoint = canDelete;
            [self removeActionForKey:kRotateActionName];
            SKAction *animation = [LREnvelopeAnimationBuilder changeEnvelopeCanDeleteState:canDelete];
            [self runAction:animation withKey:kRotateActionName];
        }
        CGPoint touchLoc = [touch locationInNode:self.parent];
        self.position = touchLoc;
    }
    self.touchedAfterGameOver = [[LRGameStateManager shared] isGameOver];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSAssert(self.userInteractionEnabled, @"User interaction should be enabled if touch is ending");
    if (self.touchedAfterGameOver)
        return;

    [super touchesEnded:touches withEvent:event];
    BOOL canDelete = [self shouldEnvelopeBeDeletedAtPosition:self.position];
    if (canDelete != self.isAtDeletionPoint) {
        self.isAtDeletionPoint = canDelete;
    }

    if (self.isAtDeletionPoint)
    {
        [self.delegate removeEnvelopeFromLetterSection:self];
    }
    else {
        [self.delegate rearrangementHasFinishedWithLetterBlock:self];
        SKAction *descale = [LREnvelopeAnimationBuilder animateToScale:1.0 withDuration:kLRCollectedEnvelopeBubbleDuration];
        [self runAction:descale];
    }
    self.touchedAfterGameOver = [[LRGameStateManager shared] isGameOver];
}

#pragma mark - Touch Helper Functions

- (void)releaseBlockForRearrangement
{
    //Move the block from being the child of the letter slot to the child of the whole letter section
    LRLetterSection *letterSection = [[(LRGameScene *)[self scene] gamePlayLayer] letterSection];
    NSAssert(self.parent, @"Only blocks in slots should be rearranged.");

    self.position = self.parentSlot.position;
    [self.parentSlot setEmptyLetterBlock];
    [letterSection addChild:self];
    [self.delegate rearrangementHasBegunWithLetterBlock:self];
}

- (BOOL) shouldEnvelopeBeDeletedAtPosition:(CGPoint)pos
{
    CGFloat currentYPos = pos.y;
    //#toy
    if (currentYPos > (kSectionHeightLetterSection + kCollectedEnvelopeSpriteDimension)/2) {
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

- (BOOL)isCollectedEnvelopeEmpty {
    return ![[self letter] length];
}

- (BOOL)isCollectedEnvelopePlaceholder {
    return ([self.letter isEqualToString:kLetterBlockHolderText]);
}

- (void)setIsAtDeletionPoint:(BOOL)isAtDeletionPoint
{
    _isAtDeletionPoint = isAtDeletionPoint;
    [self.delegate deletabilityHasChangedTo:isAtDeletionPoint forLetterBlock:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
