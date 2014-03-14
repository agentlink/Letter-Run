//
//  LRSubmitButton.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRSubmitButton.h"
#import "LRGameStateManager.h"

@interface LRSubmitButton ()
@property (strong, nonatomic) SKLabelNode *label;
@end

@implementation LRSubmitButton

#pragma mark - Public Functions

- (id) init {
    self = [super initWithColor:[LRColor submitButtonDisabledColor]
                           size:CGSizeMake(kLetterBlockDimension, kLetterBlockDimension)];
    if (self) {
        [self addChild:self.label];
    }
    return self;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    //Update the color
    self.color = (userInteractionEnabled) ? [SKColor greenColor] : [SKColor lightGrayColor];
}

#pragma mark - Private Functions

- (SKLabelNode *)label
{
    if (!_label) {
        UIFont *labelFont = [LRFont submitButtonFont];
        _label = [SKLabelNode labelNodeWithFontNamed:labelFont.fontName];
        _label.fontSize = labelFont.pointSize;
        _label.text = @"Submit";
        _label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
    return _label;
}

#pragma mark - Touch

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location) && ![[LRGameStateManager shared] isGameOver])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SUBMIT_WORD object:nil];
        }
    }
}

@end
