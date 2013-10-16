//
//  LRLetterBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"
#import "LRConstants.h"
#import "LRCollisionManager.h"

#import "LRGameScene.h"
#import "LRGameStateManager.h"
#import "LRLetterSlot.h"

@interface LRLetterBlock ()
@end
@implementation LRLetterBlock

#pragma mark - Initializers/Set Up
+ (LRLetterBlock*) letterBlockWithLetter:(NSString*)letter;
{
    return [[LRLetterBlock alloc] initWithLetter:letter];
}

- (id) initWithLetter:(NSString *)letter
{
    if (self = [super initWithColor:[SKColor blackColor] size:CGSizeMake(LETTER_BLOCK_SIZE, LETTER_BLOCK_SIZE)]) {
        self.letter = letter;
        [self createObjectContent];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) createObjectContent
{
    SKLabelNode *letterLabel = [[SKLabelNode alloc] init];
    letterLabel.text = self.letter;
    letterLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - letterLabel.frame.size.height/2);
    [self addChild:letterLabel];
}

@end
