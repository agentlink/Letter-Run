//
//  LRMainGameSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMainGameSection.h"
#import "LRGameStateManager.h"
#import "LRLetterBlockBuilder.h"
#import "LRRowManager.h"
#import "LRPositionConstants.h"
#import "LRMailman.h"
#import "LRMovingBlockBuilder.h"

static const CGFloat kMailmanAreaWidth          = 60.0;

@interface LRMainGameSection () <LRMovingBlockTouchDelegate>

//Children
@property SKSpriteNode *backgroundImage;
@property (nonatomic, weak) LRMailman *mailman;
//Row logic
@property LRRowManager *rowManager;
@property NSMutableArray *envelopesOnScreen;
@property int envelopeZPosition;

@end

@implementation LRMainGameSection
#pragma mark - Initialization Methods -

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.envelopesOnScreen = [NSMutableArray new];
        self.rowManager = [LRRowManager new];
        self.envelopeTouchEnabled = YES;
        self.envelopeZPosition = zPos_MovingEnvelope_Initial;
    }
    return self;
}

- (void)createSectionContent
{
    //Mailman section
    LRMailmanArea *mailmanArea = [[LRMailmanArea alloc] initWithSize:CGSizeMake(kMailmanAreaWidth, self.size.height)];
    mailmanArea.position = (CGPoint){(mailmanArea.size.width - self.size.width)/2, 0};
    self.mailmanArea = mailmanArea;
    [self addChild:self.mailmanArea];
    
    LRMailman *manford = [LRMailman new];
    manford.position = CGPointMake(10, self.position.y);
    [self.mailmanArea addChild:manford];
    self.mailman = manford;
    
}

- (void)setEnvelopeBuilder:(LRMovingBlockBuilder *)envelopeBuilder
{
    _envelopeBuilder = envelopeBuilder;
    _envelopeBuilder.screenDelegate = self;
    [self addChild:_envelopeBuilder];
}

#pragma mark Letter Addition and Removal
- (void)clearMainGameSection
{
    [self.rowManager resetLastRow];
    [self removeChildrenInArray:self.envelopesOnScreen];
    [self.envelopesOnScreen removeAllObjects];
}


#pragma mark - Delegate Methods -
#pragma mark LRMovingBlockBuilderDelegate
- (void)addMovingBlockToScreen:(LRMovingEnvelope *)movingBlock
{
    //Add the object to the slot manager
    movingBlock.row = [self.rowManager generateNextRow];
    movingBlock.touchDelegate = self;
    [self.envelopesOnScreen addObject:movingBlock];
    [self addChild:movingBlock];
}

- (void)removeMovingBlockFromScreen:(LRMovingEnvelope *)envelope
{
    [self.envelopesOnScreen removeObject:envelope];
    [self removeChildrenInArray:@[envelope]];
}


#pragma mark LRMovingBlockTouchDelegate Methods

- (void)playerSelectedMovingBlock:(LRMovingEnvelope *)movingBlock
{
    movingBlock.selected = !movingBlock.selected;
}

#pragma mark LRGameStateDelegate Methods

+ (SKAction *)gameOverSlowDownAction
{
    SKAction *slowDown = [SKAction speedTo:0.0 duration:1.5];
    slowDown.timingMode = SKActionTimingEaseIn;
    return slowDown;
}

- (void)gameStateNewGame
{
    [self.envelopeBuilder startMovingBlockGeneration];
    self.envelopeTouchEnabled = YES;
    [self clearMainGameSection];

    //Start the mailman run
    [self.mailman startRun];
}

- (void)gameStateGameOver
{
    [self.envelopeBuilder stopMovingBlockGeneration];
    self.envelopeTouchEnabled = NO;
    for (LRMovingEnvelope *envelope in self.envelopesOnScreen) {
        [envelope runAction:[LRMainGameSection gameOverSlowDownAction]];
    }
    [self.mailman stopRun];
}

#pragma mark - Helper Methods

- (void)setEnvelopeTouchEnabled:(BOOL)envelopeTouchEnabled
{
    _envelopeTouchEnabled = envelopeTouchEnabled;
    for (LRMovingEnvelope *envelope in self.envelopesOnScreen) {
        envelope.userInteractionEnabled = envelopeTouchEnabled;
    }
}

- (CGFloat)zPositionForNextEnvelope
{
    CGFloat retVal = self.envelopeZPosition;
    self.envelopeZPosition += zDiff_Envelope_Envelope;
    return retVal;
}


@end
