//
//  LRFallingLetterList.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 12/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//


#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>
#import "LRMovingEnvelope.h"

@interface LRRowManager : NSObject

///Returns the row that the next letter should be in
- (int)generateNextRow;
///Resets the row values. Call this after a game over
- (void)resetLastRow;

@end
