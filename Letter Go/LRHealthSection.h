//
//  LRHealthSection.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRScreenSection.h"

@interface LRHealthSection : LRScreenSection

- (void) submitWord:(NSString*) word;

- (CGFloat) percentHealth;
- (void) moveHealthByPercent:(CGFloat)percent;

@end
