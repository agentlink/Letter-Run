//
//  LRSharedTextureCache.h
//  Letter Go
//
//  Created by Gabe Nicholas on 5/24/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRSharedTextureCache : SKNode

+(LRSharedTextureCache*)shared;
///returns a shared texture with a given name. If the texture doesn't exists, it creates it
- (SKTexture*)textureWithName:(NSString *)name;
///preloads all the texture atlases used in the game
- (void)preloadTextureAtlasesWithCompletion:(void(^)())handler;

@end
