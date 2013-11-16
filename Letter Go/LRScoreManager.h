//
//  LRScoreManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRScoreManager : SKNode
+ (LRScoreManager*) shared;

- (void) submitWord:(NSDictionary*)wordDict;
- (int) score;
+ (int) scoreForWord:(NSString*)word;
+ (int) scoreForWordWithLoveLetters:(NSDictionary*)word;

@property (readonly) NSMutableArray *submittedWords;

@end
