//
//  UIFont+LRAdditions.m
//  Letter Go
//
//  Created by Gabe Nicholas on 7/3/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "UIFont+LRAdditions.h"

@implementation UIFont (LRAdditions)

+ (void)preloadFonts
{
    for (NSString *fontName in [UIFont _fontNamesToPreload])
    {
        SKLabelNode *node = [SKLabelNode labelNodeWithFontNamed:fontName];
        node.text = @"You have to set text for it to preload, bro";
    }
}

+ (NSString *)lr_displayFontRegular {
    return @"LeagueGothic-Regular";
}

+ (NSString *)lr_displayFontItalic {
    return @"LeagueGothic-Italic";
}

+ (NSString *)lr_letterBlockFont {
    return @"GothamBold";
}

+ (NSArray *)_fontNamesToPreload
{
    return @[@"Helvetica", [UIFont lr_letterBlockFont], [UIFont lr_displayFontItalic], [UIFont lr_displayFontRegular]];
}

@end
