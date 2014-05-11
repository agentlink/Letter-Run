//
//  LRMailman.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/11/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMailman.h"
#import "LRMovingEnvelope.h"
#import "LRMovingBlockBuilder.h"

//#toy
static CGFloat const LRMailmanMovementToEnvelopeGenerationRatio = .9;

@interface LRMailman ()
@property (nonatomic, readwrite) NSUInteger currentRow;
@end

@implementation LRMailman

#pragma mark - Public Methods

- (id) init
{
    if (self = [super initWithImageNamed:@"manford"])
    {
        //TODO: remove this hack
        self.currentRow = 2;
        self.xScale = 1.2;
        self.yScale = 1.2;
        [LRManfordAIManager shared].movementDelegate = self;
    }
    return self;
}

#pragma mark - LRManfordMovementDelegate Methods

- (void)nextEnvelopeRowChangedToRow:(NSUInteger)row
{
    //If there is now no selected envelope...
    if (row == kLRManfordAIManagerEmptyRow) {
        return;
    }
    self.currentRow = row;
}

#pragma mark - Private Methods

- (void)setCurrentRow:(NSUInteger)currentRow
{
    SKAction *moveRowAction = [self _moveMailmanActionFromRow:_currentRow toRow:currentRow];
    if (moveRowAction) {
        [self runAction:moveRowAction];
    }
    _currentRow = currentRow;
}

- (SKAction *)_moveMailmanActionFromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow
{
    CGPoint envelopePoint = [LRMovingEnvelope envelopePositionForRow:toRow];
    CGPoint newManfordPos = CGPointMake(self.position.x, envelopePoint.y);

    NSInteger rowDiff = fromRow - toRow;
    NSUInteger netRowDiff = ABS(rowDiff);
    if (netRowDiff <= 0) {
        return nil;
    }
    
    //The time that Manford take to move to an envelope should be relative to how quickly the envelopes are generating.
    CGFloat maxManfordTravelTime = [[LRMovingBlockBuilder shared] blockGenerationInterval] * LRMailmanMovementToEnvelopeGenerationRatio;
    
    CGFloat duration = netRowDiff * maxManfordTravelTime/(kLRRowManagerNumberOfRows - 1);
    SKAction *movement = [SKAction moveTo:newManfordPos duration:duration];
    movement.timingMode = SKActionTimingEaseInEaseOut;
    return movement;
}
@end
