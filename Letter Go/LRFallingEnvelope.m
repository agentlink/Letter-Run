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
#import "LRCurveBuilder.h"

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
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LETTER_CLEARED object:self userInfo:[self removeLetterDictionary]];
        [self removeFromParent];
    }
}

# pragma mark - Movement Function

- (void) dropEnvelopeWithSwing
{
    //Get the height that the envelope has to fall
    LRGamePlayLayer *gpl = [(LRGameScene*)[self scene] gamePlayLayer];
    CGFloat gameSceneHeight = gpl.frame.size.height;
    
    __block CGFloat bottomEdgeHeight = 0;
    [gpl enumerateChildNodesWithName:NAME_SPRITE_BOTTOM_EDGE usingBlock:^(SKNode *node, BOOL *stop) {
        bottomEdgeHeight =  ABS((0 - gameSceneHeight)/2 - node.position.y - node.frame.size.height);
    }];
    CGFloat dropHeight = gameSceneHeight - bottomEdgeHeight;
    
    //Get the array of curve actions to run
    NSMutableArray *curveArray;
    if ([[LRDifficultyManager shared] lettersFallVertically]) {
        curveArray = [NSMutableArray arrayWithArray:[LRCurveBuilder verticalFallingLetterActionsWithHeight:dropHeight andSwingCount:(arc4random()%3 + 3)]];
    }
    else {
        curveArray = [NSMutableArray arrayWithArray:[LRCurveBuilder horizontalLetterActionForDistance:SCREEN_WIDTH + SIZE_LETTER_BLOCK * 2]];
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
            [self flingEnvelopeToMailmanWithCurve];
        }
    }
}

- (void) setSlot:(int)newSlot
{
    _slot = newSlot;
    if ([[LRDifficultyManager shared] lettersFallVertically]) {
        float leftBuffer = SIZE_LETTER_BLOCK * 3 - SCREEN_WIDTH/2;
        float letterDistance = SIZE_LETTER_BLOCK * 1.7;
        int offsetDegree = 10;
        int offset = arc4random()%(offsetDegree*2) - offsetDegree;
        self.position = CGPointMake(newSlot * letterDistance + leftBuffer + (float)offset, self.position.y);
    }
    else {
        //TODO: get constant for grass height
        CGFloat grassHeight = 20;
        CGFloat topBufferSize = SIZE_HEIGHT_HEALTH_SECTION + SIZE_LETTER_BLOCK/2;
        CGFloat bottomBufferSize = SIZE_HEIGHT_LETTER_SECTION + SIZE_LETTER_BLOCK/2 + grassHeight;
        //TODO: replace with constant number of slots
        CGFloat letterDistance = (SCREEN_HEIGHT - topBufferSize - bottomBufferSize) / 3;
        
        CGFloat xPos = SCREEN_WIDTH/2 + SIZE_LETTER_BLOCK;
        if ([[LRDifficultyManager shared] mailmanScreenSide] == MailmanScreenRight) {
            xPos *= -1;
        }
        
        self.position = CGPointMake(xPos, -SCREEN_HEIGHT/2 + bottomBufferSize + letterDistance * newSlot);
    }
    NSLog(@"Letter %@ generated at position (%f, %f)", self.letter, self.position.x, self.position.y);
}

#pragma mark - Movement Functions

- (void) flingEnvelopeToMailmanWithCurve
{
    CGPoint end = [(LRGamePlayLayer*)self.parent flungEnvelopeDestination];
    CGPoint start = self.position;
    CGPoint c1 = CGPointMake((start.x + end.x)/2, (start.y + end.y)/2);
    CGPoint c2 = CGPointMake((start.x + end.x)/4, end.y - end.y/4);
    
    LRBezierPath *flingPath = [LRCurveBuilder bezierWithStart:start c1:c1 c2:c2 end:end];
    float curveLength = [LRCurveBuilder lengthOfBezierCurve:flingPath];
    float duration = curveLength/(.5 * SCREEN_WIDTH);
    
    SKAction *followPath = [SKAction followPath:[flingPath CGPath] asOffset:NO orientToPath:NO duration:duration];
    followPath.timingMode = SKActionTimingEaseIn;
    
    SKAction *pause = [SKAction waitForDuration:duration/2];
    SKAction *zoom = [SKAction scaleTo:0 duration:duration/2];
    SKAction *pauseAndZoom = [SKAction sequence:@[pause, zoom]];
    SKAction *moveAndShrink = [SKAction group:@[followPath, pauseAndZoom]];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADDED_LETTER object:self userInfo:[self addLetterDictionary]];
    
    //And notify that a new slot is empty
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LETTER_CLEARED object:self userInfo:[self removeLetterDictionary]];
    [self removeFromParent];
    
}

static inline CGFloat distanceBetweenPoints(CGPoint a, CGPoint b) {
    CGFloat xDiff = a.x - b.x;
    CGFloat yDiff = a.y - b.y;
    return sqrtf(powf(xDiff, 2) + powf(yDiff, 2));
}


#pragma mark - User Info Dictionary Functions
- (NSDictionary*) removeLetterDictionary
{
    NSDictionary *dict = [NSMutableDictionary dictionaryWithObject:self forKey:@"envelope"];
    return dict;
}

- (NSDictionary*) addLetterDictionary
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[self.letter, [NSNumber numberWithBool:self.loveLetter]] forKeys:@[KEY_GET_LETTER, KEY_GET_LOVE]];
    return dict;
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
