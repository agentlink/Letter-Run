//
//  LRParallaxNode.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGameStateDelegate.h"

@interface LRParallaxNode : SKSpriteNode <LRGameStateDelegate>

+ (LRParallaxNode*) nodeWithImageNamed:(NSString*)imageName;
- (SKSpriteNode *) repeatingSprite;

- (void) moveNodeBy:(CGFloat)distance;

@property (nonatomic) CGFloat relativeSpeed;
@property (nonatomic) CGFloat xOffset;

@end
