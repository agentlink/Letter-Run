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
#import "LRSharedTextureCache.h"
#import "LRPositionConstants.h"
#import "LRScoreManager.h"
#import "LRProgressManager.h"

static NSString * const kLRMailmanRunningActionKey = @"manford running";

@interface LRMailman ()
@property (nonatomic, readwrite) NSUInteger currentRow;
@property (nonatomic) NSArray *runningTextures;
@end

@implementation LRMailman

#pragma mark - Public Methods

- (id) init
{
    SKTexture *manfordTexture = [LRMailman _initialTexture];
    if (self = [super initWithTexture:manfordTexture])
    {
        self.xScale = .7;
        self.yScale = .7;
        self.zPosition = zPos_Mailman;
        [self setCurrentRow:2 animated:NO];
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

- (void)setCurrentRow:(NSUInteger)currentRow animated:(BOOL)animated
{
    if (animated) {
        SKAction *moveRowAction = [self _moveMailmanActionFromRow:_currentRow toRow:currentRow];
        if (moveRowAction) {
            [self runAction:moveRowAction];
        }
    }
    else {
        self.position = [self mailmanPositionForRow:currentRow];
    }
    _currentRow = currentRow;
}

- (void)setCurrentRow:(NSUInteger)currentRow
{
    [self setCurrentRow:currentRow animated:YES];
}

- (CGPoint)mailmanPositionForRow:(NSUInteger)row
{
    CGPoint rowPoint = [LRMovingEnvelope envelopePositionForRow:row];
    CGFloat manfordMargin = 30;
    rowPoint = CGPointMake(self.position.x, rowPoint.y + manfordMargin);
    return rowPoint;
}

#pragma mark - Running

- (void)startRun
{
    if ([self actionForKey:kLRMailmanRunningActionKey]) {
        NSLog(@"WARNING: Manford is already performing running action");
        return;
    }
    //Load the running textures
    NSMutableArray *textures = [NSMutableArray new];
    for (int i = 1; i < 11; i++)
    {
        NSString *fileName = [NSString stringWithFormat:@"Manford-Run%i", i];
        SKTexture *texture = [[LRSharedTextureCache shared] textureForName:fileName];
        [textures addObject:texture];
    }
    self.runningTextures = textures;
    [self _runRecursiveRunAnimation];
}

-(void)_runRecursiveRunAnimation
{
    CGFloat initialTimePerFrame = 0.08;
    CGFloat timePerFrameDecreasePerLevel = .003;
    CGFloat minTimePerFrame = 0.052;
    CGFloat potentialTimePerFrame = initialTimePerFrame - ([[LRProgressManager shared] level] - 1) * timePerFrameDecreasePerLevel;
    CGFloat timePerFrame = MAX(minTimePerFrame, potentialTimePerFrame);
    
    SKAction *animation = [SKAction animateWithTextures:self.runningTextures timePerFrame:timePerFrame resize:YES restore:NO];
    //The distance Manford has run depends on how often the animation goes
    SKAction *completion = [SKAction runBlock:^{
        [[LRScoreManager shared] increaseDistanceByValue:1];
        [self _runRecursiveRunAnimation];
    }];
    [self runAction:[SKAction sequence:@[animation, completion]] withKey:kLRMailmanRunningActionKey];

}

- (void)stopRun
{
    [self removeActionForKey:kLRMailmanRunningActionKey];
    self.texture = [LRMailman _initialTexture];
}

#pragma mark - Private Methods

- (SKAction *)_moveMailmanActionFromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow
{
    CGPoint envelopePoint = [self mailmanPositionForRow:toRow];
    CGPoint newManfordPos = CGPointMake(self.position.x, envelopePoint.y);
    
    NSInteger rowDiff = fromRow - toRow;
    NSUInteger netRowDiff = ABS(rowDiff);
    if (netRowDiff <= 0) {
        return nil;
    }
    
    //The time that Manford take to move to an envelope should be relative to how quickly the envelopes are generating.
    CGFloat duration = [LRMailman _manfordMovementDurationForRowDifference:netRowDiff];
    SKAction *movement = [SKAction moveTo:newManfordPos duration:duration];
    movement.timingMode = SKActionTimingEaseInEaseOut;
    return movement;
}

//This function returns how long Manford takes to move a given amount of rows
+ (CGFloat)_manfordMovementDurationForRowDifference:(NSUInteger)rowDiff
{
    CGFloat blockInterval = [LRMovingBlockBuilder blockGenerationInterval];
    //Manford should move slower for shorter distances
    CGFloat maxMultiplier = 1.4;
    CGFloat speedDiffPerRow = .2;
    CGFloat multiplier = maxMultiplier - (rowDiff * speedDiffPerRow);
    CGFloat maxManfordTravelTime =  blockInterval * multiplier;
    CGFloat duration = rowDiff * maxManfordTravelTime/(kLRRowManagerNumberOfRows - 1);
    return duration;
}

+ (SKTexture *)_initialTexture
{
     return [[LRSharedTextureCache shared] textureForName:@"Manford-Run1"];
}

@end
