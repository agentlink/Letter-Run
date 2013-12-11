//
//  LRLetterBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"
#import "LRCollisionManager.h"
#import "LRGameScene.h"
#import "LRGameStateManager.h"
#import "LRLetterSlot.h"
#import "LRPositionConstants.h"

@interface LRLetterBlock ()
@property SKSpriteNode *envelopeSprite;
@property (readwrite) BOOL loveLetter;
@end
@implementation LRLetterBlock

#pragma mark - Initializers/Set Up
+ (LRLetterBlock*) letterBlockWithLetter:(NSString*)letter loveLetter:(BOOL)love;
{
    return [[LRLetterBlock alloc] initWithLetter:letter loveLetter:love];
}

- (id) initWithLetter:(NSString*)letter loveLetter:(BOOL)love
{
    if (self = [super initWithColor:[SKColor clearColor] size:CGSizeMake(LETTER_BLOCK_SIZE, LETTER_BLOCK_SIZE)]) {
        self.letter = letter;
        self.userInteractionEnabled = YES;
        self.loveLetter = love;
        [self createObjectContent];
    }
    return self;
}

- (void) createObjectContent
{
    //Letter Label
    SKLabelNode *letterLabel = [[SKLabelNode alloc] init];
    letterLabel.text = self.letter;
    letterLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - letterLabel.frame.size.height/2);
    letterLabel.fontColor = [SKColor blackColor];
    letterLabel.zPosition += zDiff_Letter_Envelope;
    
    [self addChild:letterLabel];
    
    //Determine which envelope sprite to use
    if ([self.letter length]) {
        NSString *fileName = (self.loveLetter) ? @"Envelope_Love.png" : @"Envelope_Normal.png";
        self.envelopeSprite = [SKSpriteNode spriteNodeWithImageNamed:fileName];
        self.envelopeSprite.xScale = LETTER_BLOCK_SIZE/self.envelopeSprite.size.width;
        self.envelopeSprite.yScale = LETTER_BLOCK_SIZE/self.envelopeSprite.size.height;
        [self addChild:self.envelopeSprite];
    }
}
@end
