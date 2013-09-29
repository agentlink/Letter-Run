//
//  LRLetterBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"

@interface LRLetterBlock ()
@end
@implementation LRLetterBlock

- (id) initWithSize:(CGSize)size andLetter:(NSString *)letter;
{
    if (self = [super initWithColor:[SKColor blackColor] size:size]) {
        self.letter = letter;
        [self createObjectContent];
        [self setUpPhysics];
    }
    return self;
}

- (void) setUpPhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.affectedByGravity = YES;
    self.physicsBody.dynamic = YES;
}

- (void) createObjectContent
{
    SKLabelNode *letterLabel = [[SKLabelNode alloc] init];
    letterLabel.text = self.letter;
    letterLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - letterLabel.frame.size.height/2);
    [self addChild:letterLabel];
    
}
@end
