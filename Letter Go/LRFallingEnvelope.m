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
#import "LRDifficultyManager.h"

@interface LRFallingEnvelope ()
@property (readwrite) BOOL loveLetter;
@property BOOL playerMovedTouch;
@property CGPoint originalPoint;
@property CGFloat pixelsPerSecond;
@end

@implementation LRFallingEnvelope

#pragma mark - Set Up/Initializing

+ (LRFallingEnvelope*) envelopeWithLetter:(NSString*)letter loveLetter:(BOOL)love
{
    return [[LRFallingEnvelope alloc] initWithLetter:letter loveLetter:love];
}


- (id) initWithLetter:(NSString*)letter loveLetter:(BOOL)love
{
    if (self = [super initWithLetter:letter loveLetter:love]) {
        self.blockState = BlockState_Falling;
        self.name = NAME_SPRITE_FALLING_ENVELOPE;
        self.pixelsPerSecond = [[LRDifficultyManager shared] flingLetterSpeed];

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
    self.physicsBody.friction = 1;
    [[LRCollisionManager shared] setBitMasksForSprite:self];
    [[LRCollisionManager shared] addContactDetectionOfSpritesNamed:NAME_SPRITE_BOTTOM_EDGE toSprite:self];
}

- (void) removePhysics {
    self.physicsBody = nil;
}

#pragma mark - Game Loop

- (void) update:(NSTimeInterval)currentTime
{
    //Only check if the block has been flung or has landed on the ground
    if (self.blockState != BlockState_BlockFlung && self.blockState != BlockState_Landed)
        return;
    
    //Get the letter's location in the scene
    CGRect sceneRect = [(LRGameScene*)self.scene window];
    CGRect letterFrame = self.frame;
    letterFrame.origin = [self.scene convertPoint:letterFrame.origin fromNode:[(LRGameScene*)self.scene gamePlayLayer]];
    
    //If the box has been flung to the letter box section
    if (!(CGRectIntersectsRect(sceneRect, letterFrame))) {
        NSMutableDictionary *dropLetterInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:self.slot] forKey:@"slot"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LETTER_CLEARED object:self userInfo:dropLetterInfo];
        [self removeFromParent];
    }
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
        bottomEdgeHeight =  ABS((0 - gameSceneHeight)/2 - node.position.y - node.frame.size.height);
    }];
    
    CGFloat dropHeight = gameSceneHeight - bottomEdgeHeight;
    
    CGFloat xDiff = -70;
    CGFloat yDiff = 0 - dropHeight/3;
    CGPoint nextPosition = CGPointMake(xDiff, yDiff);

    CGFloat rotation = 10;
    CGFloat duration = 2;
    
    NSMutableArray *curveArray = [NSMutableArray array];

    for (int i = 0; i < 3; i++)
    {
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointMake(0, 0)];
        [bezierPath addCurveToPoint: nextPosition controlPoint1: CGPointMake(0, 0) controlPoint2: CGPointMake(0, nextPosition.y)];
        nextPosition.x *= -1;

        //Set the last position to land at the original x point
        if (i == 1) nextPosition.x /= 2;
        
        SKAction *followPath = [SKAction followPath:[bezierPath CGPath] asOffset:YES orientToPath:NO duration:duration];
        SKAction *rotate;
        if (i == 0) {
            followPath.timingMode = SKActionTimingEaseOut;
            rotate = [SKAction rotateToAngle:0 -(rotation * M_PI)/180 duration:duration];
        }
        else if (i == 1) {
            followPath.timingMode = SKActionTimingEaseInEaseOut;
            rotate = [SKAction rotateToAngle:(rotation * M_PI)/180 duration:duration];
        }
        else {
            followPath.timingMode = SKActionTimingEaseIn;
            rotate = [SKAction rotateToAngle:0 duration:duration];
        }
        rotate.timingMode = followPath.timingMode;
        [curveArray addObject:[SKAction group:@[followPath, rotate]]];
    }
    [curveArray addObject:[SKAction runBlock:^{
        if (self.blockState != BlockState_BlockFlung)
            self.blockState = BlockState_Landed;
    }]];
    [self runAction:[SKAction sequence:curveArray] withKey:ACTION_ENVELOPE_DROP];
}

#pragma mark - Touch Functions

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        if (self.blockState == BlockState_BlockFlung)
            return;
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location))
        {
            self.playerMovedTouch = FALSE;
            self.blockState = BlockState_PlayerIsHolding;
            
            self.originalPoint = self.position;
            [self removeActionForKey:ACTION_ENVELOPE_DROP];
            [self removePhysics];
        }
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (!CGRectContainsPoint(self.frame, location) && self.blockState != BlockState_BlockFlung)
        {
            self.blockState = BlockState_BlockFlung;
            [self flingTowardsLocation:location];
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        //If the block is falling but wasn't flung
        if (self.blockState != BlockState_BlockFlung) {
            self.blockState = BlockState_BlockFlung;
            [self flingEnvelopeToMailman];
        }
    }
}

- (void) setSlot:(int)newSlot
{
    _slot = newSlot;

    float leftBuffer = LETTER_BLOCK_SIZE * 3 - SCREEN_WIDTH/2;
    float letterDistance = LETTER_BLOCK_SIZE * 1.7;
    int offsetDegree = 10;
    int offset = arc4random()%(offsetDegree*2) - offsetDegree;
    self.position = CGPointMake(newSlot * letterDistance + leftBuffer + (float)offset, self.position.y);
}

#pragma mark - Movement Functions

- (void) flingEnvelopeToMailman
{
    CGPoint destination = [(LRGamePlayLayer*)self.parent flungEnvelopeDestination];
    float distance = distanceBetweenPoints(destination, self.originalPoint);
    
    SKAction *move = [SKAction moveTo:destination duration:distance/self.pixelsPerSecond];
    SKAction *pause = [SKAction waitForDuration:distance/(2 * self.pixelsPerSecond)];
    SKAction *zoom = [SKAction scaleTo:0 duration:distance/(2 * self.pixelsPerSecond)];
    SKAction *pauseAndZoom = [SKAction sequence:@[pause, zoom]];
    SKAction *moveAndShrink = [SKAction group:@[move, pauseAndZoom]];
    
    SKAction *offScreen = [SKAction runBlock:^{
        [self addLetterToLetterSection];
    }];
    [self runAction:[SKAction sequence:@[moveAndShrink, offScreen]] withKey:ACTION_ENVELOPE_FLING];
}

- (void) flingTowardsLocation:(CGPoint)location
{
    float xDiff = location.x - self.originalPoint.x;
    float yDiff = location.y - self.originalPoint.y;
    float xToYRatio = xDiff / (ABS(xDiff) + ABS(yDiff));
    float yToXRatio = yDiff / (ABS(xDiff) + ABS(yDiff));
    
    CGPoint destination = CGPointMake(xToYRatio * SCREEN_WIDTH * 2, yToXRatio * SCREEN_WIDTH * 2);
    CGFloat distance = distanceBetweenPoints(self.originalPoint, destination);
    SKAction *move = [SKAction moveTo:destination duration:distance/self.pixelsPerSecond];
    [self runAction:move withKey:ACTION_ENVELOPE_FLING];
}

- (void) addLetterToLetterSection
{
    //Add the letter
    NSMutableDictionary *addLetterInfo = [NSMutableDictionary dictionaryWithObjects:@[self.letter, [NSNumber numberWithBool:self.loveLetter]] forKeys:@[KEY_GET_LETTER, KEY_GET_LOVE]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADDED_LETTER object:self userInfo:addLetterInfo];
    
    //And notify that a new slot is empty
    NSMutableDictionary *dropLetterInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:self.slot] forKey:@"slot"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LETTER_CLEARED object:self userInfo:dropLetterInfo];
    [self removeFromParent];
    
}

static inline CGFloat distanceBetweenPoints(CGPoint a, CGPoint b) {
    CGFloat xDiff = a.x - b.x;
    CGFloat yDiff = a.y - b.y;
    return sqrtf(powf(xDiff, 2) + powf(yDiff, 2));
}

#pragma mark - Destruction Functions

- (void) envelopeHitMailman
{
    //Player cannot touch envelope once it has hit the mailman
    [self setUserInteractionEnabled:NO];
    
    //TODO: replace this with explosion (currently a fade)
    SKAction *fade = [SKAction fadeAlphaTo:0 duration:1];
    SKAction *removeSelf = [SKAction runBlock: ^{
        [self removeFromParent];
    }];
    [self runAction:[SKAction sequence:@[fade, removeSelf]]];
}

@end
