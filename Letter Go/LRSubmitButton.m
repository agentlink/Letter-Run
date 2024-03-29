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

- (id) init
{
    if (self = [super initWithImageNamed:@"submit-button" withDisabledOption:YES])
    {
        self.color = [UIColor redColor];
        [self setTouchUpInsideTarget:self action:@selector(submitButtonSelected)];
        self.isEnabled = NO;
    }
    return self;
}

#pragma mark - Touch

- (void)submitButtonSelected
{
    if (![[LRGameStateManager shared] isGameOver]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSubmitWord object:nil];
    }
    self.isEnabled = NO;
}

@end
