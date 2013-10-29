//
//  LRDifficultyManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/15/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDifficultyManager.h"

@interface LRDifficultyManager ()
@property (nonatomic) int level;
@end

@implementation LRDifficultyManager

# pragma mark - Init Functions
static LRDifficultyManager *_shared = nil;
+ (LRDifficultyManager*) shared
{
    @synchronized (self)
    {
		if (!_shared) {
			_shared = [[LRDifficultyManager alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init]) {
        
        //TODO: replace with NSUserDefaults call when DevPause menu added
        self.level = 1;
        self.totalScoreFactor = 1.2;
        self.scorePerLetter = 10;
        self.healthBarToScoreRatio = .75;
        self.scoreIncreaseStyle = IncreaseStyle_Exponential;

        //Add levelScoreIncreaseFactor value if style is not IncreaseStyle_None
        self.levelScoreIncreaseStyle = IncreaseStyle_Linear;
        self.levelScoreIncreaseFactor = 50;
        self.initialNextLevelScore = 150;
        
        self.healthFallsOverTime = YES;

    }
    return self;
}

#pragma mark - Getters and Setters
- (void) increaseLevel {
    self.level++;
}

- (void) resetLevel {
    self.level = 0;
}

@end
