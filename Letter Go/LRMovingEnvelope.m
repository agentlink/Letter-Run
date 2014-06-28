//
//  LRMovingBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMovingEnvelope.h"
#import "LREnvelopeAnimationBuilder.h"
#import "LRMovingBlockBuilder.h"
#import "LRRowManager.h"
#import "LRManfordAIManager.h"
#import "LRSharedTextureCache.h"
#import "LRMultipleLetterGenerator.h"

const LRPaperColor kLRMovingEnvelopeHiddenPaperColor = kLRPaperColorBlue;
const LRPaperColor kLRMovingEnvelopeShiftingPaperColor = kLRPaperColorPink;

static CGFloat const kLRMovingBlockTouchSizeExtraWidth  = 25.0;
static CGFloat const kLRMovingBlockTouchSizeExtraHeight = 35.0;
static CGFloat const kLRMovingBlockSpriteDimension     = 48.0;

NSString * const kLRMovingBlockShiftLetterActionName = @"shift letter";
NSString * const kLRMovingBlockName = @"Moving envelope";

@interface LRMovingEnvelope ()
@property (nonatomic, weak) id<LRManfordAIManagerSelectionDelegate> aiDelegate;
@property (nonatomic, strong) SKSpriteNode *envelopeSprite;
@property (nonatomic, readwrite) NSUInteger envelopeID;
@property (nonatomic, strong) NSArray *shiftingLetterArray;
@property (nonatomic) NSUInteger currentShiftedLetterIndex;
@end

@interface LRMovingEnvelopeShiftingLabel : SKLabelNode;
@property (nonatomic) BOOL enableLetterShift;
- (id)initWithLetters:(NSArray *)letters;
@end

@implementation LRMovingEnvelope

#pragma mark - Initialization/Setters -

+ (LRMovingEnvelope *)movingBlockWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor
{
    return [[LRMovingEnvelope alloc] initWithLetter:letter paperColor:paperColor];
}

- (id)initWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor
{
    CGSize size = CGSizeMake(kLRMovingBlockSpriteDimension, kLRMovingBlockSpriteDimension);
    if (self = [super initWithLetter:letter paperColor:paperColor size:size])
    {
        self.name = kLRMovingBlockName;
        SKSpriteNode *envelopeSprite = [self _envelopeSpriteForLetter:letter paperColor:paperColor];

        [self _updateLabel];
        if (envelopeSprite) {
            //Correctly position the envelope sprite
            self.envelopeSprite = envelopeSprite;
            self.envelopeSprite.anchorPoint = CGPointMake(0.5, 0);
            CGPoint envPosition = self.envelopeSprite.position;
            envPosition.y -= self.envelopeSprite.size.height/2;
            self.envelopeSprite.position = envPosition;
            [self addChild:self.envelopeSprite];
        }
        
        CGSize touchSize = self.size;
        touchSize.width += kLRMovingBlockTouchSizeExtraWidth;
        touchSize.height += kLRMovingBlockTouchSizeExtraHeight;
        self.touchSize = touchSize;

        self.aiDelegate = [LRManfordAIManager shared];
    }
    return self;
}

- (void)updateForRemoval
{
    [self.aiDelegate envelopeCollectedWithID:self.envelopeID];
    self.userInteractionEnabled = NO;
}

+ (CGPoint)envelopePositionForRow:(NSUInteger)row
{
    NSAssert(row < kLRRowManagerNumberOfRows, @"Slot %u exceeds the proper number of rows", (unsigned)row);
    
    CGFloat yDiff = kSectionHeightMainSection/(kLRRowManagerNumberOfRows + 1);
    CGFloat lowestPosition = 0 - kSectionHeightMainSection/2 + yDiff * .5;
    CGFloat xPos = SCREEN_WIDTH/2 + kLRMovingBlockSpriteDimension;
    CGFloat yPos = lowestPosition + yDiff * row;
    
    return CGPointMake(xPos, yPos);
}

- (SKSpriteNode *)_envelopeSpriteForLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor
{
    BOOL placeholderBlock = [LRLetterBlock isLetterPlaceholder:letter];
    SKSpriteNode *envelopeSprite;
    NSString *fileName = [LRMovingEnvelope stringFromPaperColor:paperColor open:NO];
    
    if (fileName) {
        SKTexture *envelopeTexture = [[LRSharedTextureCache shared] textureWithName:fileName];
        envelopeSprite = [[SKSpriteNode alloc] initWithTexture:envelopeTexture];
        envelopeSprite.size = CGSizeMake(self.size.width - self.touchSize.width,
                                         self.size.height - self.touchSize.height);
        if (placeholderBlock) {
            envelopeSprite.alpha = .2;
        }
    }
    
    return envelopeSprite;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //If the letter is touched, go to the delegate
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location) && self.userInteractionEnabled) {
            [self.touchDelegate playerSelectedMovingBlock:self];
        }
    }
}

#pragma mark - Setters + Getters

- (void)setRow:(NSUInteger)row
{
    _row = row;
    self.position = [LRMovingEnvelope envelopePositionForRow:row];
    self.envelopeID = [[LRManfordAIManager shared] nextEnvelopeIDForRow:row];
}

- (void)setSelected:(BOOL)selected
{
    [self.envelopeSprite runAction:[self _selectedAnimation]];
    _selected = selected;
    _envelopeOpen = selected;
    [self.aiDelegate envelopeSelectedChanged:selected withID:self.envelopeID];
    
    if (selected) {
        [self removeActionForKey:kLRMovingBlockShiftLetterActionName];
    }
    else if (self.paperColor == kLRMovingEnvelopeShiftingPaperColor) {
        [self runAction:[self _shiftLetterAction] withKey:kLRMovingBlockShiftLetterActionName];
    }
}

- (void)setEnvelopeOpen:(BOOL)envelopeOpen
{
    NSString *textureName = [LRMovingEnvelope stringFromPaperColor:self.paperColor open:envelopeOpen];
    self.envelopeSprite.texture = [[LRSharedTextureCache shared] textureWithName:textureName];
    _envelopeOpen = envelopeOpen;
}

+ (NSString *)stringFromPaperColor:(LRPaperColor)paperColor open:(BOOL)open
{
    NSString *spriteName =  [NSString stringWithFormat:@"envelope-%@", [LRLetterBlock stringValueForPaperColor:paperColor]];
    int append = open ? 4 : 1;
    spriteName = [spriteName stringByAppendingString:[NSString stringWithFormat:@"-%i", append]];
    return spriteName;
}


#pragma mark - Private Methods

- (SKAction *)_selectedAnimation
{
    NSMutableArray *textures = [NSMutableArray new];
    NSString *baseTextureName = [LRMovingEnvelope stringFromPaperColor:self.paperColor open:self.selected];
    int endCount = (self.selected) ? 1 : 4;
    int startCount = (self.selected) ? 4 : 1;
    int diff = (self.selected) ? -1 : 1;
    for (int i = startCount; i != endCount + diff; i+= diff) {
        NSString *textureName = [baseTextureName stringByReplacingCharactersInRange:NSMakeRange(baseTextureName.length - 1, 1)withString:[NSString stringWithFormat:@"%i", i]];
        SKTexture *texture = [[LRSharedTextureCache shared] textureWithName:textureName];
        [textures addObject:texture];
    }
    
    SKAction *animation = [SKAction animateWithTextures:textures timePerFrame:.05 resize:YES restore:NO];
    return animation;
}

- (void)_updateLabel
{
    NSAssert(kLRMovingEnvelopeHiddenPaperColor != kLRMovingEnvelopeShiftingPaperColor, @"Unable to set paper label to both shifting and hidden");
    if (self.paperColor == kLRMovingEnvelopeHiddenPaperColor) {
        self.letterLabel.text = [LRMovingEnvelope _letterForHiddenPaperColor];
    }
    else if (self.paperColor == kLRMovingEnvelopeShiftingPaperColor && ![self.letter isEqualToString:@"  "]) {
        self.shiftingLetterArray = [[LRMultipleLetterGenerator shared] generateMultipleLetterList];
        [self runAction:[self _shiftLetterAction] withKey:kLRMovingBlockShiftLetterActionName];
    }
}

+ (NSString *)_letterForHiddenPaperColor
{
    return @"?";
}

- (SKAction *)_shiftLetterAction
{
    NSAssert(self.shiftingLetterArray && self.shiftingLetterArray.count > 0, @"Shift letter action requires an array of letters");
    self.currentShiftedLetterIndex = -1;
    CGFloat letterChangeInterval = [LRMovingBlockBuilder blockScreenCrossTime] / [self.shiftingLetterArray count];
    SKAction *wait = [SKAction waitForDuration:letterChangeInterval];
    SKAction *shiftLetter = [SKAction runBlock:^{
        self.currentShiftedLetterIndex = (_currentShiftedLetterIndex == self.shiftingLetterArray.count - 1) ? 0 : self.currentShiftedLetterIndex + 1;
        NSString *letter = self.shiftingLetterArray[self.currentShiftedLetterIndex];
        self.letter = letter;
    }];
    SKAction *waitAndShift = [SKAction sequence:@[shiftLetter, wait]];
    SKAction *shiftForever = [SKAction repeatActionForever:waitAndShift];
    return shiftForever;
}

@end
