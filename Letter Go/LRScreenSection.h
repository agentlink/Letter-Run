//
//  LRScreenSection.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRGameStateDelegate.h"
@interface LRScreenSection : SKSpriteNode <LRGameStateDelegate>

- (id) initWithSize:(CGSize)size;

@end
