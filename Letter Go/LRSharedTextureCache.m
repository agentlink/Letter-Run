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
- (void)preloadTextureAtlasesWithCompletion:(void(^)())handler
{
    NSMutableArray *textureAtlases = [NSMutableArray new];

    //letter atlases
    NSArray *letterColors = @[@"Blue", @"Pink", @"Yellow"];
    for (NSString *letterColor in letterColors) {
        NSString *atlasName = [NSString stringWithFormat:@"Letter_%@", letterColor];
        SKTextureAtlas *envelopeAtlas = [SKTextureAtlas atlasNamed:atlasName];
        [textureAtlases addObject:envelopeAtlas];
    }
    
    //button atlases
    SKTextureAtlas *pauseAtlas = [SKTextureAtlas atlasNamed:@"Button_Pause"];
    SKTextureAtlas *submitAtlas = [SKTextureAtlas atlasNamed:@"Button_Submit"];
    [textureAtlases addObjectsFromArray:@[submitAtlas, pauseAtlas]];
    
    //Manford atlases
    SKTextureAtlas *manfordAtlas = [SKTextureAtlas atlasNamed:@"Manford"];
    [textureAtlases addObject:manfordAtlas];
    
    [self _preloadAtlasesInArray:textureAtlases startIndex:0 completion:handler];
}

- (void)_preloadAtlasesInArray:(NSArray *)atlases startIndex:(int)index completion:(void(^)())handler
{
    if (index == atlases.count) {
        if (handler)
            handler();
        return;
    }
    SKTextureAtlas *atlas = atlases[index];
    //add the textures to the texture dictionary
    for (NSString *textureName in atlas.textureNames) {
        self.textureDict[textureName] = [atlas textureNamed:textureName];
    }
    //preload the texture atlas and on completion, do the next one
    [atlas preloadWithCompletionHandler:^{
        [self _preloadAtlasesInArray:atlases startIndex:index+1 completion:handler];
    }];
}

@end
