//
//  LRFont.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/28/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRFont.h"

@implementation LRFont

+ (void)preloadFonts
{
    for (NSString *fontName in [LRFont _fontNamesToPreload])
    {
        SKLabelNode *node = [SKLabelNode labelNodeWithFontNamed:fontName];
        node.text = @"You have to set text for it to preload, bro";
    }
}

+ (LRFont *)displayTextFontWithSize:(CGFloat)size {
    return (LRFont *)[LRFont fontWithName:@"LeagueGothic-Italic" size:size];
}
+ (LRFont *)letterBlockFont {
    return (LRFont *)[UIFont fontWithName:@"GothamBold" size:32];
}

+ (NSArray *)_fontNamesToPreload
{
    return @[@"Helvetica", @"LeagueGothic-Italic", @"GothamBold"];
}

@end
