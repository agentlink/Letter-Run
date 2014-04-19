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
#import "LRSlotManager.h"
#import "LRDifficultyManager.h"

static const CGFloat kMailmanAreaWidth          = 70.0;

@interface LRMainGameSection () <LRMovingBlockTouchDelegate>

//Children
@property SKSpriteNode *backgroundImage;
//Slot logic
@property LRSlotManager *letterSlotManager;
@property NSMutableArray *envelopesOnScreen;
@property LRMovingBlockBuilder *envelopeBuilder;

@end

@implementation LRMainGameSection
#pragma mark - Initialization Methods -

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.envelopesOnScreen = [NSMutableArray new];
        self.letterSlotManager = [LRSlotManager new];
        self.envelopeTouchEnabled = YES;
    }
    return self;
}

- (void)createSectionContent
{
    //Background
    self.backgroundImage = [[SKSpriteNode alloc] initWithImageNamed:@"mainSection-background"];
    self.backgroundImage.size = self.size;
    [self addChild:self.backgroundImage];
    
    //Mailman section
    LRMailmanArea *mailmanArea = [[LRMailmanArea alloc] initWithSize:CGSizeMake(kMailmanAreaWidth, self.size.height)];
    mailmanArea.position = (CGPoint){(mailmanArea.size.width - self.size.width)/2, 0};
    self.mailmanArea = mailmanArea;
    [self addChild:self.mailmanArea];
    
}

#pragma mark - Update Loop Methods -
#pragma mark Time Methods
- (void)update:(NSTimeInterval)currentTime
{
    if (!self.envelopeBuilder) {
        self.envelopeBuilder = [LRMovingBlockBuilder shared];
        self.envelopeBuilder.delegate = self;
        [self addChild:self.envelopeBuilder];
        [self.envelopeBuilder startMovingBlockGeneration];
    }
    [self _checkEnvelopesForRemoval];
}

#pragma mark Letter Addition and Removal
#pragma mark LRMovingBlockBuilderDelegate
- (void)addMovingBlockToScreen:(LRMovingEnvelope *)movingBlock
{
    //Add the object to the slot manager
    [self.letterSlotManager addEnvelope:movingBlock];
    movingBlock.touchDelegate = self;
    [self.envelopesOnScreen addObject:movingBlock];
    [self addChild:movingBlock];
}

///Pass in an array of LRMovingBlocks to delete
- (void)removeMovingBlocksFromScreen:(NSArray *)letterBlocks
{
    //Remove the envelope from the screen and the array
    [self.envelopesOnScreen removeObjectsInArray:letterBlocks];
    [self removeChildrenInArray:letterBlocks];
}

- (void)clearMainGameSection
{
    [self.letterSlotManager resetSlots];
    [self removeChildrenInArray:self.envelopesOnScreen];
    [self.envelopesOnScreen removeAllObjects];
}

#pragma mark Letter Movement/Touch

- (void)setEnvelopeTouchEnabled:(BOOL)envelopeTouchEnabled
{
    _envelopeTouchEnabled = envelopeTouchEnabled;
    for (LRMovingEnvelope *envelope in self.envelopesOnScreen) {
        envelope.userInteractionEnabled = envelopeTouchEnabled;
    }
}

- (void)_shiftEnvelopesForTimeDifference:(CGFloat)timeDifference
{
    CGFloat secondsToCrossScreen = 3.2;
    //TODO: get this from the difficulty manager
    CGFloat pixelsPerSecond = SCREEN_WIDTH / secondsToCrossScreen;
    for (LRMovingEnvelope* envelope in self.envelopesOnScreen) {
        //Shift the block down...
        CGFloat distance = pixelsPerSecond * timeDifference;
        envelope.position = CGPointMake(envelope.position.x - distance,
                                     envelope.position.y);
    }
}

- (void)_checkEnvelopesForRemoval
{
    NSMutableArray *envelopesToRemove = [NSMutableArray new];
    for (LRMovingEnvelope* envelope in self.envelopesOnScreen)
    {
        if ([self _envelopeHasCrossedCollectionThreshold:envelope])
        {
            if (envelope.selected) {
                [self.letterAdditionDelegate addEnvelopeToLetterSection:envelope];
            }
            [envelopesToRemove addObject:envelope];
        }
    }
    [self removeMovingBlocksFromScreen:envelopesToRemove];
}

- (BOOL)_envelopeHasCrossedCollectionThreshold:(LRMovingEnvelope *)envelope
{
    return (envelope.position.x < self.mailmanArea.position.x);
}

#pragma mark - Delegate Methods -
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
}

- (void)gameStateGameOver
{
    self.envelopeTouchEnabled = NO;
}

- (void)gameStatePaused:(NSTimeInterval)currentTime
{
    [self enumerateChildNodesWithName:NAME_SPRITE_MOVING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        [node setUserInteractionEnabled:NO];
    }];
}

- (void)gameStateUnpaused:(NSTimeInterval)currentTime
{
    [self enumerateChildNodesWithName:NAME_SPRITE_MOVING_ENVELOPE usingBlock:^(SKNode *node, BOOL *stop) {
        [node setUserInteractionEnabled:YES];
    }];
}
@end
