//
//  LRGameStateManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/4/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRGameStateManager : SKNode

+ (LRGameStateManager*) shared;
- (BOOL) isLetterSectionFull;

@end
