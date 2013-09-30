//
//  LRLetterBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"
#import "LRSpriteNameConstants.h"
#import "LRCollisionManager.h"
#import "LRLetterBlock+Touch.h"

@interface LRLetterBlock ()
@end
@implementation LRLetterBlock

+ (LRLetterBlock*) letterBlockWithSize:(CGSize)size andLetter:(NSString*)letter
{
    return [[LRLetterBlock alloc] initWithSize:size andLetter:letter];
}

- (id) initWithSize:(CGSize)size andLetter:(NSString *)letter;
{
    if (self = [super initWithColor:[SKColor blackColor] size:size]) {
        self.name = NAME_LETTER_BLOCK;
        self.letter = letter;
        [self createObjectContent];
        [self setUpPhysics];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) setUpPhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.affectedByGravity = YES;
    self.physicsBody.dynamic = YES;
    [[LRCollisionManager shared] setBitMasksForSprite:self];
    [[LRCollisionManager shared] addCollisionDetectionOfSpriteNamed:NAME_BOTTOM_EDGE toSprite:self];
}

- (void) setUpSwipedPhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.dynamic = YES;
    [[LRCollisionManager shared] setBitMasksForSprite:self];

}

- (void) removePhysics
{
    self.physicsBody = nil;
}

- (void) createObjectContent
{
    SKLabelNode *letterLabel = [[SKLabelNode alloc] init];
    letterLabel.text = self.letter;
    letterLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - letterLabel.frame.size.height/2);
    [self addChild:letterLabel];
    
}

- (BOOL) isLetterBlockEmpty
{
    return ![[self letter] length];
}

@end
