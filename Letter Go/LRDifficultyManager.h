//
//  LRDifficultyManager.h
//  Letter Go
//
//  Created by Gabe Nicholas on 5/29/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LRMultipleLetterGenerator.h"

@interface LRDifficultyManager : SKNode

+ (LRDifficultyManager *)shared;

///Returns the available paper colors as an array of NSNumbers
- (NSSet *)availablePaperColors;

@end
