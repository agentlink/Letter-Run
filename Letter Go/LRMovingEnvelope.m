//
//  LRMovingBlock.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRMovingEnvelope.h"
#import "LREnvelopeAnimationBuilder.h"
#import "LRRowManager.h"
#import "LRManfordAIManager.h"

static CGFloat const kLRMovingBlockTouchSizeExtraWidth  = 25.0;
static CGFloat const kLRMovingBlockTouchSizeExtraHeight = 35.0;
static CGFloat const kLRMovingBlockSpriteDimension     = 48.0;
NSString * const kLRMovingBlockName = @"Moving envelope";

@interface LRMovingEnvelope ()
@property (nonatomic, weak) id<LRManfordAIManagerSelectionDelegate> aiDelegate;
@property (nonatomic, strong) SKSpriteNode *glow;
@property (nonatomic, strong) SKSpriteNode *envelopeSprite;
@property (nonatomic, readwrite) NSUInteger envelopeID;
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

        self.color = [LRColor debugColor1];
        SKSpriteNode *envelopeSprite = [self _envelopeSpriteForLetter:letter paperColor:paperColor];
        if (envelopeSprite) {
            //Correctly position the envelope sprite
            self.envelopeSprite = envelopeSprite;
            self.envelopeSprite.anchorPoint = CGPointMake(0.5, 0);
            CGPoint envPosition = self.envelopeSprite.position;
            envPosition.y -= self.envelopeSprite.size.height/2;
            self.envelopeSprite.position = envPosition;
            [self addChild:self.envelopeSprite];
        }
        [self _setGlowEnabled:NO];
        [self addChild:self.glow];

        CGSize touchSize = self.size;
        touchSize.width += kLRMovingBlockTouchSizeExtraWidth;
        touchSize.height += kLRMovingBlockTouchSizeExtraHeight;
        self.touchSize = touchSize;
        self.aiDelegate = [LRManfordAIManager shared];
    }
    return self;
}

- (SKSpriteNode *)glow {
    if (!_glow) {
        _glow = [SKSpriteNode spriteNodeWithImageNamed:@"envelope-glow"];
        _glow.zPosition = -1;
        _glow.alpha = 0.0;
    }
    return _glow;
}

- (void)setRow:(NSUInteger)row
{
    _row = row;
    self.position = [LRMovingEnvelope envelopePositionForRow:row];
    self.envelopeID = [[LRManfordAIManager shared] nextEnvelopeIDForRow:row];
}

- (void)updateForRemoval
{
    [self.aiDelegate envelopeCollectedWithID:self.envelopeID];
    self.userInteractionEnabled = NO;
}

+ (CGPoint)envelopePositionForRow:(NSUInteger)row
{
    NSAssert(row < kLRRowManagerNumberOfRows, @"Slot %i exceeds the proper number of rows", row);
    
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
        envelopeSprite = [SKSpriteNode spriteNodeWithImageNamed:fileName];
        envelopeSprite.size = CGSizeMake(self.size.width - self.touchSize.width,
                                         self.size.height - self.touchSize.height);
        if (placeholderBlock) {
            envelopeSprite.alpha = .2;
        }
    }
    
    return envelopeSprite;
}

#pragma mark - Touch Functions + Helpers
#pragma mark -

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //If the eltter is touched, go to the delegate
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location) && self.userInteractionEnabled) {
            [self.touchDelegate playerSelectedMovingBlock:self];
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    [self.envelopeSprite runAction:[self _selectedAnimation]];
    _selected = selected;
    [self.aiDelegate envelopeSelectedChanged:selected withID:self.envelopeID];
}

- (void)setEnvelopeOpen:(BOOL)envelopeOpen
{
    self.envelopeSprite.texture = [SKTexture textureWithImageNamed:[LRMovingEnvelope stringFromPaperColor:self.paperColor open:envelopeOpen]];
    _envelopeOpen = envelopeOpen;
}

- (SKAction *)_selectedAnimation
{
    NSMutableArray *textures = [NSMutableArray new];
    NSString *baseTextureName = [LRMovingEnvelope stringFromPaperColor:self.paperColor open:self.selected];
    int endCount = (self.selected) ? 1 : 4;
    int startCount = (self.selected) ? 4 : 1;
    int diff = (self.selected) ? -1 : 1;
    for (int i = startCount; i != endCount + diff; i+= diff) {
        NSString *textureName = [baseTextureName stringByReplacingCharactersInRange:NSMakeRange(baseTextureName.length - 1, 1)withString:[NSString stringWithFormat:@"%i", i]];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [textures addObject:texture];
    }
    
    SKAction *animation = [SKAction animateWithTextures:textures timePerFrame:.04 resize:YES restore:NO];
    return animation;
}
- (void)_setGlowEnabled:(BOOL)enabled
{
    CGFloat fadedAlpha = 0.7;
    CGFloat fadeDuration = 0.15;

    CGFloat newEnvelopeAlpha = (enabled) ? fadedAlpha : 1.0;
    CGFloat newGlowAlpha = (enabled) ? fadedAlpha : 0.0;

    SKAction *fadeEnvelope = [SKAction fadeAlphaTo:newEnvelopeAlpha duration:fadeDuration];
    SKAction *fadeGlow = [SKAction fadeAlphaTo:newGlowAlpha duration:fadeDuration];
    [self runAction:fadeEnvelope];
    [self.glow runAction:fadeGlow];
    
}

+ (NSString *)stringFromPaperColor:(LRPaperColor)paperColor open:(BOOL)open
{
    NSString *spriteName;
    switch (paperColor) {
        case kLRPaperColorBlue:
            spriteName = @"envelope-blue";
            break;
        case kLRPaperColorPink:
            spriteName = @"envelope-pink";
            break;
        case kLRPaperColorYellow:
            spriteName = @"envelope-yellow";
            break;
        case kLRPaperColorNone:
            spriteName = @"envelope-glow";
            break;
    }
    if (paperColor != kLRPaperColorNone) {
        int append = open ? 4 : 1;
        spriteName = [spriteName stringByAppendingString:[NSString stringWithFormat:@"-%i", append]];
    }
    return spriteName;
}

@end
