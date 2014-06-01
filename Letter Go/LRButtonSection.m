//
//  LRButtonSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 3/28/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRButtonSection.h"

@interface LRButtonSection ()
@end

@implementation LRButtonSection

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.color = [LRColor buttonSectionColor];
    }
    return self;
}

- (void)createSectionContent
{
    [self addChild:self.submitButton];
}

- (LRSubmitButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [LRSubmitButton new];
        _submitButton.anchorPoint = CGPointMake(.5, 1);
        _submitButton.position = CGPointMake(0, self.size.height/2);
    }
    return _submitButton;
}


@end
