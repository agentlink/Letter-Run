//
//  UIFont+LRAdditions.h
//  Letter Go
//
//  Created by Gabe Nicholas on 7/3/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (LRAdditions)

+ (void)preloadFonts;

+ (NSString *)lr_displayFontRegular;
+ (NSString *)lr_displayFontItalic;
+ (NSString *)lr_letterBlockFont;

@end
