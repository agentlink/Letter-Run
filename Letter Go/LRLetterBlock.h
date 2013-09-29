//
//  LRLetterBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/29/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRLetterBlock : SKSpriteNode
@property NSString *letter;

- (id) initWithSize:(CGSize)size andLetter:(NSString *)letter;

@end
