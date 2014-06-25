//
//  LRFont.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/28/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRFont : UIFont

+ (void)preloadFonts;
+ (LRFont *)displayTextFontWithSize:(CGFloat)size;
+ (LRFont *)letterBlockFont;

@end
