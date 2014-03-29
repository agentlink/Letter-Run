//
//  LRFont.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/28/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRFont.h"

@implementation LRFont

+ (LRFont *)displayTextFontWithSize:(CGFloat)size {
    return (LRFont *)[LRFont fontWithName:@"LeagueGothic-Italic" size:size];
}
+ (LRFont *)letterBlockFont {
    return (LRFont *)[UIFont fontWithName:@"GothamBold" size:32];
}

@end
