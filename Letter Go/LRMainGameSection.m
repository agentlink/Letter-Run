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
#import "LRMailTruck.h"
#import "LRShadowRoundedRect.h"

@interface LRMainGameSection () <LRMovingBlockTouchDelegate>

//Children
@property SKSpriteNode *backgroundImage;
@property (nonatomic, weak) LRMailman *mailman;
//Row logic
@property LRRowManager *rowManager;
@property NSMutableArray *envelopesOnScreen;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_levelStarted) name:GAME_STATE_STARTED_LEVEL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_levelFinished) name:GAME_STATE_FINISHED_LEVEL object:nil];
        
        //Manford the Mailman
        LRMailman *manford = [LRMailman new];
        CGFloat manfordLeftMargin = 40;
        //TODO: make this be Manford's size
        CGFloat manfordX = -self.size.width/2 + manfordLeftMargin;
        manford.position = CGPointMake(manfordX, self.position.y);
        [self addChild:manford];
        self.mailman = manford;
        
        //Mailtruck
        LRMailTruck *truck = [[LRMailTruck alloc] init];
        [self addChild:truck];
    }
    return self;
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

- (void)setEnvelopeTouchEnabled:(BOOL)envelopeTouchEnabled
{
    _envelopeTouchEnabled = envelopeTouchEnabled;
    for (LRMovingEnvelope *envelope in self.envelopesOnScreen) {
        envelope.userInteractionEnabled = envelopeTouchEnabled;
    }
}

+ (SKAction *)gameOverSlowDownAction
{
    SKAction *slowDown = [SKAction speedTo:0.0 duration:1.5];
    slowDown.timingMode = SKActionTimingEaseIn;
    return slowDown;
}

#pragma mark LRMovingBlockTouchDelegate Methods

- (void)playerSelectedMovingBlock:(LRMovingEnvelope *)movingBlock
{
    movingBlock.selected = !movingBlock.selected;
}


#pragma mark LRGameStateDelegate Methods

- (void)gameStateNewGame
{
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

#pragma mark - Private Methods
- (void)_levelStarted
{
    [self.envelopeBuilder startMovingBlockGeneration];
}

- (void)_levelFinished
{
    [self.envelopeBuilder stopMovingBlockGeneration];
    [self clearMainGameSection];
}
#pragma mark - Helper Methods


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
