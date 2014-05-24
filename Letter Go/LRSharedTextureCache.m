//
//  LRSharedTextureCache.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/24/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRSharedTextureCache.h"

@interface LRSharedTextureCache()
@property (nonatomic, strong) NSMutableDictionary *textureDict;
@end
@implementation LRSharedTextureCache

static LRSharedTextureCache *_shared = nil;

#pragma mark - Public Methods
+ (LRSharedTextureCache *)shared
{
    //This @synchronized line is for multithreading
    @synchronized (self)
    {
		if (!_shared)
        {
			_shared = [[LRSharedTextureCache alloc] init];
		}
	}
	return _shared;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.textureDict = [NSMutableDictionary new];
    [self _loadTextureAtlases];
    return self;
}

- (SKTexture *)textureForName:(NSString *)name
{
    //check if the texture exists. If it does, return
    if (self.textureDict[name]) {
        return self.textureDict[name];
    }
    SKTexture *newTexture = [SKTexture textureWithImageNamed:name];
    self.textureDict[name] = newTexture;
    return newTexture;
}

#pragma Private Methods
- (void)_loadTextureAtlases
{
    NSMutableArray *textureAtlases = [NSMutableArray new];

    //letter texture assets
    NSArray *letterColors = @[@"Blue", @"Pink", @"Yellow"];
    for (NSString *letterColor in letterColors) {
        NSString *atlasName = [NSString stringWithFormat:@"Letter_%@", letterColor];
        SKTextureAtlas *envelopeAtlas = [SKTextureAtlas atlasNamed:atlasName];
        [textureAtlases addObject:envelopeAtlas];
    }
    
    //add the textures to the texture dictionary
    for (SKTextureAtlas *atlas in textureAtlases) {
        for (NSString *textureName in atlas.textureNames) {
            self.textureDict[textureName] = [atlas textureNamed:textureName];
        }
    }
}

@end
