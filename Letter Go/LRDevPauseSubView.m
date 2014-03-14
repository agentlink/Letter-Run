//
//  LRDevPauseSubView.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/11/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDevPauseSubView.h"

@implementation LRDevPauseSubView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame andDictionary:(NSDictionary *)dict {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}
- (void)reloadValue {
    NSAssert(0, @"Error: reloadValue should be overwritten");
}

@end
