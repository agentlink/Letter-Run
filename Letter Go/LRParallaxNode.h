//
//  LRParallaxNode.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGameUpdateDelegate.h"

@interface LRParallaxNode : SKSpriteNode <LRGameUpdateDelegate>

+ (LRParallaxNode*) nodeWithImageNamed:(NSString*)imageName;
- (SKSpriteNode *) repeatingSprite;

- (void) moveNodeBy:(CGFloat)distance;

@property (nonatomic) CGFloat relativeSpeed;
@property (nonatomic) CGFloat xOffset;

@end
