//
//  LRGamePlayLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGamePlayLayer.h"
#import "LRLetterBlockGenerator.h"
#import "LRNameConstants.h"
#import "LRCollisionManager.h"

@implementation LRGamePlayLayer

- (id) init
{
    if (self = [super init])
    {
        //Code here :)
        [self createLayerContent];
        [self setUpPhysics];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropLetter) name:NOTIFICATION_DROP_LETTER object:nil];
    }
    return self;
}

- (void) createLayerContent
{
    //Create the three sections
    CGFloat healthHeight = 3;
    CGFloat letterHeight = 70;
    self.healthSection = [[LRHealthSection alloc] initWithSize:CGSizeMake(self.size.width, healthHeight)];
    self.healthSection.position = CGPointMake(self.position.x - self.size.width/2, self.size.height/2 - self.healthSection.size.height/2);
    [self addChild:self.healthSection];

    self.letterSection = [[LRLetterSection alloc] initWithSize:CGSizeMake(self.size.width, letterHeight)];
    self.letterSection.position = CGPointMake(self.position.x - self.size.width/2, 0 - self.size.height/2 + self.letterSection.size.height/2);
    [self addChild:self.letterSection];
    
    //TEMPORARY: blocks will be continuously created by LRLetterBlockGenerator
    [self addChild:[LRLetterBlockGenerator createLetterBlock]];
}

- (void) setUpPhysics
{
    //Add a line so that the block doesn't just fall forever
    float edgeHeight = self.letterSection.position.y + self.letterSection.size.height/2;
    CGPoint leftScreen = CGPointMake(0 - self.size.width /2, edgeHeight);
    CGPoint rightScreen = CGPointMake (self.size.width/2, edgeHeight);
    SKPhysicsBody *blockEdge = [SKPhysicsBody bodyWithEdgeFromPoint:leftScreen toPoint:rightScreen];
    SKSpriteNode *blockEdgeSprite = [[SKSpriteNode alloc] init];
    blockEdgeSprite.name = NAME_BOTTOM_EDGE;
    blockEdgeSprite.physicsBody = blockEdge;
    [[LRCollisionManager shared] setBitMasksForSprite:blockEdgeSprite];
    [self addChild:blockEdgeSprite];
}

- (void) dropLetter
{
    [self addChild:[LRLetterBlockGenerator createLetterBlock]];
}
@end
