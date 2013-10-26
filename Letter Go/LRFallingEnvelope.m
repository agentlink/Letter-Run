//
//  LRFallingEnvelope.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/14/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRFallingEnvelope.h"
#import "LRCollisionManager.h"
#import "LRGameStateManager.h"
#import "LRGameScene.h"

@interface LRFallingEnvelope ()
@property BOOL playerMovedTouch;
@property CGPoint originalPoint;
@end
@implementation LRFallingEnvelope

#pragma mark - Set Up/Initializing

+ (LRFallingEnvelope*) envelopeWithLetter:(NSString*)letter
{
    return [[LRFallingEnvelope alloc] initWithLetter:letter];
}


- (id) initWithLetter:(NSString*)letter
{
    if (self = [super initWithLetter:letter]) {
        self.blockState = BlockState_Falling;
        self.name = NAME_SPRITE_FALLING_ENVELOPE;
        [self setUpPhysics];
    }
    return self;
}

#pragma mark - Physics Functions

- (void) setUpPhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.dynamic = YES;
    [[LRCollisionManager shared] setBitMasksForSprite:self];
    [[LRCollisionManager shared] addCollisionDetectionOfSpriteNamed:NAME_SPRITE_BOTTOM_EDGE toSprite:self];
}

- (void) setUpSwipedPhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.dynamic = YES;
    [[LRCollisionManager shared] setBitMasksForSprite:self];
    //Make it bounce off the bottom if the section is full
    if ([[LRGameStateManager shared] isLetterSectionFull])
        [[LRCollisionManager shared] addCollisionDetectionOfSpriteNamed:NAME_SPRITE_BOTTOM_EDGE toSprite:self];
}

- (void) removePhysics
{
    self.physicsBody = nil;
}

# pragma mark - Movement Function
- (void) dropEnvelopeWithSwing
{
    //Create the Bezier curves
    //http://tinyurl.com/beziercurveref
    
    //Get the height that the envelope has to fall
    LRGamePlayLayer *gpl = [(LRGameScene*)[self scene] gamePlayLayer];
    CGFloat gameSceneHeight = gpl.frame.size.height;
    
    __block CGFloat bottomEdgeHeight = 0;
    [gpl enumerateChildNodesWithName:NAME_SPRITE_BOTTOM_EDGE usingBlock:^(SKNode *node, BOOL *stop) {
        bottomEdgeHeight =  ABS((0 - gameSceneHeight)/2 - node.position.y);
    }];
    
    CGFloat dropHeight = gameSceneHeight - bottomEdgeHeight;
    
    CGFloat xDiff = -70;
    CGFloat yDiff = 0 - dropHeight/3;
    CGPoint nextPosition = CGPointMake(xDiff, yDiff);

    NSMutableArray *curveArray = [NSMutableArray array];
    for (int i = 0; i < 3; i++)
    {
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointMake(0, 0)];
        [bezierPath addCurveToPoint: nextPosition controlPoint1: CGPointMake(0, 0) controlPoint2: CGPointMake(0, nextPosition.y)];
        nextPosition.x *= -1;
        
        //Set the last position to land at the original x point
        if (i == 1) nextPosition.x /= 2;
        
        SKAction *followPath = [SKAction followPath:[bezierPath CGPath] asOffset:YES orientToPath:NO duration:2];
        if (i == 0) followPath.timingMode = SKActionTimingEaseOut;
        else if (i == 1) followPath.timingMode = SKActionTimingEaseInEaseOut;
        else followPath.timingMode = SKActionTimingEaseIn;
        
        [curveArray addObject:followPath];
    }
    [self runAction:[SKAction sequence:curveArray] withKey:ACTION_DROP_ENVELOPE];
}

# pragma mark - Game Loop Checks

- (void) update:(NSTimeInterval)currentTime
{
    //Only check if the block has been flung
    if (self.blockState != BlockState_BlockFlung)
        return;

    //Get the letter's location in the scene
    CGRect sceneRect = [(LRGameScene*)self.scene window];
    sceneRect.origin = [self convertPoint:sceneRect.origin fromNode:self.scene];
    CGRect letterFrame = self.frame;
    letterFrame.origin = [self convertPoint:self.frame.origin fromNode:self.parent];
    
    NSMutableDictionary *dropLetterInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:self.slot] forKey:@"slot"];
    //If the box has been flung to the letter box section
    if (CGRectContainsRect([(LRGameScene*)[self scene] gamePlayLayer].letterSection.frame, self.frame))
    {
        //Post the notification
        NSMutableDictionary *addLetterInfo = [NSMutableDictionary dictionaryWithObject:self.letter forKey:KEY_GET_LETTER];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADDED_LETTER object:self userInfo:addLetterInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DROP_LETTER object:self userInfo:dropLetterInfo];
        [self removeFromParent];
    }
    //If the box is outside the screen and has been flung
    else if (!CGRectIntersectsRect(sceneRect, letterFrame)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DROP_LETTER object:self userInfo:dropLetterInfo];
        [self removeFromParent];
    }
}

#pragma mark - Touch Functions

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location))
        {
            self.playerMovedTouch = FALSE;
            self.blockState = BlockState_PlayerIsHolding;
            
            self.originalPoint = self.position;
            [self removeActionForKey:ACTION_DROP_ENVELOPE];
            self.zPosition += 5;
        
            [self removePhysics];
        }
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (!CGRectContainsPoint(self.frame, location))
        {
            [self flingTowardsLocation:location];
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        self.zPosition -= 5;
        //If the block is falling but wasn't flung
        if (self.blockState == BlockState_PlayerIsHolding) {
            //Move off screen (TODO: replace with removal)
            self.position = CGPointMake(10000, 10000);
            self.blockState = BlockState_BlockFlung;
        }
    }
}


- (void) flingTowardsLocation:(CGPoint)location
{
    [self setUpSwipedPhysics];
    float xDiff = location.x - self.originalPoint.x;
    float yDiff = location.y - self.originalPoint.y;
    float xToYRatio = xDiff / (ABS(xDiff) + ABS(yDiff));
    float yToXRatio = yDiff / (ABS(xDiff) + ABS(yDiff));
    
    float speedFactor = 600;
    self.physicsBody.velocity = CGVectorMake(speedFactor * xToYRatio, speedFactor * yToXRatio);
    self.blockState = BlockState_BlockFlung;
}

- (void) setSlot:(int)newSlot
{
    _slot = newSlot;
    self.position = CGPointMake(newSlot * 125 - 100, self.position.y);
}

@end
