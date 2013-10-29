//
//  LRParallaxNode.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRObject.h"

@interface LRParallaxNode : LRObject

+ (LRParallaxNode*) nodeWithImageNamed:(NSString*)imageName;

@property CGFloat relativeSpeed;

@end
