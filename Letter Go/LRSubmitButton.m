//
//  LRSubmitButton.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRSubmitButton.h"
#import "LRGameStateManager.h"

static const CGFloat kSubmitButtonFontSize = 12;

@interface LRSubmitButton ()
@property (strong, nonatomic) SKLabelNode *label;
@end

@implementation LRSubmitButton

#pragma mark - Public Functions

- (id) initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size])
    {
        [self addChild:self.label];
    }
    return self;
}

- (void) setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    //Update the color
    self.color = (userInteractionEnabled) ? [SKColor greenColor] : [SKColor lightGrayColor];
}

#pragma mark - Private Functions

- (SKLabelNode*) label
{
    if (!_label) {
        _label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        _label.text = @"Submit";
        _label.fontSize = kSubmitButtonFontSize;
        _label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
    return _label;
}

#pragma mark - Touch

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
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
