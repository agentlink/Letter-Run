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
    if (self = [super initWithSize:size]) {
        [self addChild:self.submitButton];
        self.color = [LRColor buttonSectionColor];

    }
    return self;
}

- (LRSubmitButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [LRSubmitButton new];
    }
    return _submitButton;
}


@end
