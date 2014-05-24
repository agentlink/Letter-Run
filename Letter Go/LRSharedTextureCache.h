//
//  LRSharedTextureCache.h
//  Letter Go
//
//  Created by Gabe Nicholas on 5/24/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRSharedTextureCache : SKNode

+(LRSharedTextureCache*) shared;

- (SKTexture*)textureForName:(NSString *)name;

@end
