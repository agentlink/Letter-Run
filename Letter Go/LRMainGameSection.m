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
        
        self.envelopeBuilder = [LRMovingBlockBuilder shared];
        self.envelopeBuilder.screenDelegate = self;
        [self addChild:self.envelopeBuilder];
        [self.envelopeBuilder startMovingBlockGeneration];
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

#pragma mark Letter Addition and Removal
- (void)clearMainGameSection
{
    [self.letterSlotManager resetSlots];
    [self removeChildrenInArray:self.envelopesOnScreen];
    [self.envelopesOnScreen removeAllObjects];
}


#pragma mark - Delegate Methods -
#pragma mark LRMovingBlockBuilderDelegate
- (void)addMovingBlockToScreen:(LRMovingEnvelope *)movingBlock
{
    //Add the object to the slot manager
    [self.letterSlotManager addEnvelope:movingBlock];
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

- (void)setEnvelopeTouchEnabled:(BOOL)envelopeTouchEnabled
{
    _envelopeTouchEnabled = envelopeTouchEnabled;
    for (LRMovingEnvelope *envelope in self.envelopesOnScreen) {
        envelope.userInteractionEnabled = envelopeTouchEnabled;
    }
}

@end
