//
//  LRGameUpdateDelegate.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/30/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol LRGameUpdateDelegate <NSObject>
@optional
- (void) update:(NSTimeInterval)currentTime;
@end