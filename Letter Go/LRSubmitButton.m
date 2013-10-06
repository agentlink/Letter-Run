//
//  LRSubmitButton.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRSubmitButton.h"
#import "LRNameConstants.h"

@interface LRSubmitButton ()
@property SKLabelNode *label;
@end

@implementation LRSubmitButton

#pragma mark - Set Up

- (id) initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size])
    {
        [self createButtonContent];
    }
    return self;
}

- (void) createButtonContent
{
    self.label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    self.label.text = @"Submit";
    self.label.fontSize = 12;
    self.label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:self.label];
}

- (void) setPlayerCanSubmitWord:(BOOL)playerCanSubmitWord
{
    if (playerCanSubmitWord)
        self.color = [SKColor greenColor];
    else
        self.color = [SKColor lightGrayColor];
    _playerCanSubmitWord = playerCanSubmitWord;
    self.userInteractionEnabled = _playerCanSubmitWord;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:[self parent]];
        if (CGRectContainsPoint(self.frame, location) && self.playerCanSubmitWord)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SUBMIT_WORD object:self];
        }
    }
}

@end
