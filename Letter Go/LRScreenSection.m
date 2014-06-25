//
//  LRScreenSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRScreenSection.h"

@implementation LRScreenSection

- (id) init
{
    NSAssert(0, @"Error: must initialize LRScreenSection with initWithSize");
    return nil;
}

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithColor:[SKColor clearColor] size:size])
    {
    }
    return self;
}

@end
