//
//  LRDifficultyManager.m
//  Letter Go
//
//  Created by Gabe Nicholas on 5/29/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRDifficultyManager.h"
#import "LRProgressManager.h"
#import "LRMovingEnvelope.h"

@implementation LRDifficultyManager
{
    NSUInteger _level;
}

static LRDifficultyManager *_shared = nil;
+ (LRDifficultyManager *)shared
{
    //This @synchronized line is for multithreading
    @synchronized (self)
    {
		if (!_shared)
        {
			_shared = [[LRDifficultyManager alloc] init];
		}
	}
	return _shared;
}

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changedLevel) name:GAME_STATE_FINISHED_LEVEL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changedLevel) name:GAME_STATE_NEW_GAME object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)_changedLevel
{
    _level = [[LRProgressManager shared] level];
    [self _updateMutlipleLetterGenerator];
}

- (void)_updateMutlipleLetterGenerator
{
    LRChainMailStyle enable = kLRChainMailStyleNone;
    LRChainMailStyle disable = kLRChainMailStyleNone;
    LRChainMailStyle randomize = kLRChainMailStyleNone;
    LRChainMailStyle unrandomize = kLRChainMailStyleNone;

    switch (_level) {
        case 0:
        case 1:
            //if it's level 1, no shifting letters should be enabled
            disable = ~kLRChainMailStyleNone;
            unrandomize = ~kLRChainMailStyleNone;
            break;
        case 2:
            enable = kLRChainMailStyleAlphabetical;
        case 3:
            enable = kLRChainMailStyleReverseAlphabetical;
            break;
        case 4:
            enable = kLRChainMailStyleAlphabetical;
            randomize = kLRChainMailStyleAlphabetical;
            break;
        case 5:
            enable = kLRChainMailStyleVowels;
            break;
        case 6:
            randomize = kLRChainMailStyleVowels;
            break;
        case 7:
            enable = kLRChainMailStyleRandom;
            break;
        case 10:
            randomize = kLRChainMailStyleVowels | kLRChainMailStyleReverseAlphabetical;
            break;
        case 15:
            disable = kLRChainMailStyleAlphabetical | kLRChainMailStyleReverseAlphabetical | kLRChainMailStyleVowels;
            break;
        default:
            break;
    }
    
    LRMultipleLetterGenerator *multipleLetterGenerator = [LRMultipleLetterGenerator shared];
    [multipleLetterGenerator setChainMailStyleEnabled:enable enabled:YES];
    [multipleLetterGenerator setChainMailStyleEnabled:disable enabled:NO];
    [multipleLetterGenerator setRandomStartForChainMailStyle:randomize enabled:YES];
    [multipleLetterGenerator setRandomStartForChainMailStyle:unrandomize enabled:NO];
}

@end
