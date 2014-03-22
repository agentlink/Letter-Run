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

typedef NS_ENUM(NSUInteger, MovementDirection)
{
    //Remove none if it doesn't get used
    MovementDirectionNone = 0,
    MovementDirectionHorizontal,
    MovementDirectionVertical
};

static const NSUInteger kMaxBounceCount = 2;
static const CGFloat kLRCollectedEnvelopeExtraTouchHeight = 10.0;
const CGFloat kLRCollectedEnvelopeHeight = kLetterBlockSpriteDimension + kLRCollectedEnvelopeExtraTouchHeight;

@interface LRCollectedEnvelope ()

@property MovementDirection movementDirection;
@property CGPoint touchOrigin;

@property (nonatomic) NSUInteger bounceCount;
@end

@implementation LRCollectedEnvelope

#pragma mark - Set Up
+ (LRCollectedEnvelope *)sectionBlockWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    return [[LRCollectedEnvelope alloc] initWithLetter:letter loveLetter:love];
}

+ (LRCollectedEnvelope *)emptySectionBlock
{
    return [[LRCollectedEnvelope alloc] initWithLetter:@"" loveLetter:NO];
}

+ (LRCollectedEnvelope *)placeholderBlock
{
    return [[LRCollectedEnvelope alloc] initWithLetter:kLetterPlaceHolderText loveLetter:NO];
}

- (id) initWithLetter:(NSString *)letter loveLetter:(BOOL)love
{
    CGSize extraTouchSize = CGSizeMake((kDistanceBetweenSlots - kLetterBlockSpriteDimension), kLRCollectedEnvelopeExtraTouchHeight);
    if (self = [super initWithLetter:letter loveLetter:love extraTouchSize:extraTouchSize]) {
        self.name = NAME_SPRITE_SECTION_LETTER_BLOCK;
        self.movementDirection = MovementDirectionNone;
        self.bounceCount = 0;
        self.slotIndex = kSlotIndexNone;
    }
    return self;
}

#pragma mark - Physics Phunctions

- (void)setUpPhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.dynamic = YES;
    //#toy
    self.physicsBody.restitution = .5;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.friction = 1;
    [[LRCollisionManager shared] setBitMasksForSprite:self];
}

- (void)setPhysicsEnabled:(BOOL)physicsEnabled
{
    if (!self.physicsBody) {
        [self setUpPhysics];
    }
    self.physicsBody.affectedByGravity = physicsEnabled;
    self.physicsBody.velocity = CGVectorMake(0, 0);
}

- (void)envelopeHitBottomBarrier
{
    
    //If the letter block has just been added, don't do anything
    if (self.physicsBody.velocity.dy <= 0) {
        //TODO: check if it's an issue that dX is changed to 0
        self.physicsBody.velocity = CGVectorMake(0, 0);
        return;
    }
    self.bounceCount++;
    //If the envelope has exceeded the bounce count...
    if (self.bounceCount == kMaxBounceCount) {
        [self stopEnvelopeBouncing];
        //And if it's a non-temporary envelope...
        if ([self.name isEqualToString: NAME_SPRITE_SECTION_LETTER_BLOCK]) {
            //...make it stop bouncing
            self.bounceCount = 0;
        }
        //But if it's a temporary envelope...
        else if ([self.name isEqualToString:kTempCollectedEnvelopeName])
        {
            //Unhide the real envelope
            [self.parent enumerateChildNodesWithName:NAME_SPRITE_SECTION_LETTER_BLOCK usingBlock:^(SKNode *node, BOOL *stop) {
                node.hidden = NO;
            }];
            //...remove it after the max bounce count
            [self removeFromParent];
        }
    }
}

- (void)stopEnvelopeBouncing
{
    self.position = CGPointZero;
    //Only stops vertical movement
    self.physicsBody.velocity = CGVectorMake(self.physicsBody.velocity.dx, 0);
}

#pragma mark - Touch Functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location))
        {
            [self stopEnvelopeBouncing];
            self.physicsEnabled = NO;
            self.touchOrigin = location;
            self.movementDirection = MovementDirectionNone;
        }
    }
}

//Swipe function is done here by checking to see how far the player moved the block
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
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
        else if (self.touchOrigin.y <= touchLoc.y) {
            self.position = CGPointMake(envelopeLoc.x, touchLoc.y);
            //while (code == code)
                //code();
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //If the scroll is horizontal, finish moving the letters
    if (self.movementDirection == MovementDirectionHorizontal) {
        [self.delegate rearrangementHasFinishedWithLetterBlock:self];
    }
    else {
        if ([self shouldEnvelopeBeDeletedAtPosition:self.position])
        {
            [self.delegate removeEnvelopeFromLetterSection:self];
        }
        else {
            self.physicsEnabled = YES;
        }
    }
    self.movementDirection = MovementDirectionNone;
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

- (void)releaseBlockForRearrangement
{
    //Move the block from being the child of the letter slot to the child of the whole letter section
    LRLetterSection *letterSection = [[(LRGameScene *)[self scene] gamePlayLayer] letterSection];
    LRLetterSlot *parentSlot = (LRLetterSlot *)[self parent];

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
    CGFloat topOffScreenRatioForDeletion = .65;
    CGFloat maxY = self.size.height * topOffScreenRatioForDeletion;
    
    return (currentYPos > maxY);
}

- (NSString *)description
{
    NSMutableString * descript = [[super description] mutableCopy];
    [descript appendFormat:@"Letter: %@", self.letter];
    return descript;
}

#pragma mark - Block State Checks

- (BOOL) isLetterBlockEmpty {
    return ![[self letter] length];
}

- (BOOL) isLetterBlockPlaceHolder {
    return ([self.letter isEqualToString:kLetterPlaceHolderText]);
}

@end
