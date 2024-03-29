//
//  LRHealthSection.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRScreenSection.h"

@interface LRHealthSection : LRScreenSection <LRGameStateDelegate>

@property (nonatomic,readonly) CGFloat percentHealth;
- (void)addScore:(NSInteger)wordScore;

@end
