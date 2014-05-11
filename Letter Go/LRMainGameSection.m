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

static const CGFloat kMailmanAreaWidth          = 70.0;

@interface LRMainGameSection () <LRMovingBlockTouchDelegate>

//Children
@property SKSpriteNode *backgroundImage;
//Row logic
@property LRRowManager *rowManager;
@property NSMutableArray *envelopesOnScreen;
@property LRMovingBlockBuilder *envelopeBuilder;
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
        
        self.envelopeBuilder = [LRMovingBlockBuilder shared];
        self.envelopeBuilder.screenDelegate = self;
        [self addChild:self.envelopeBuilder];
        [self.envelopeBuilder startMovingBlockGeneration];
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
    [self.mailmanArea addChild:manford];
    
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

- (void)gameStateNewGame
{
    [self.envelopeBuilder startMovingBlockGeneration];
    self.envelopeTouchEnabled = YES;
    [self clearMainGameSection];
}

- (void)gameStateGameOver
{
    [self.envelopeBuilder stopMovingBlockGeneration];
    self.envelopeTouchEnabled = NO;
}

- (void)gameStatePaused
{
    [self enumerateChildNodesWithName:NAME_SPRITE_MOVING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        [node setUserInteractionEnabled:NO];
    }];
    self.paused = YES;
    self.envelopeBuilder.paused = YES;
}

- (void)gameStateUnpaused
{
    [self enumerateChildNodesWithName:NAME_SPRITE_MOVING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        [node setUserInteractionEnabled:YES];
    }];
    self.paused = YES;
    self.envelopeBuilder.paused = NO;
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
