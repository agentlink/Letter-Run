//
//  LRDictionaryChecker.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRDictionaryChecker : SKNode

//Futures (threading)

+ (LRDictionaryChecker*) shared;
- (BOOL)checkForWordInDictionary:(NSString*)word;

@end
