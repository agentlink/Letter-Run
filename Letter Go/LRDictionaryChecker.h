//
//  LRDictionaryChecker.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRDictionaryChecker : SKNode

+ (LRDictionaryChecker*) shared;
- (BOOL)checkForWordInSet:(NSString*)word;
@end
