//
//  LRValueLabelNode.h
//  Letter Go
//
//  Created by Gabe Nicholas on 6/4/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRValueLabelNode : SKLabelNode

- (id)initWithFontNamed:(NSString *)fontName initialValue:(NSInteger)value;
- (void)updateValue:(NSInteger)value animated:(BOOL)animated;
@property (nonatomic, readonly) NSInteger value;

@end
