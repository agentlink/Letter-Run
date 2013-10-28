//
//  LRDifficultyManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/15/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDifficultyManager.h"

@interface LRDifficultyManager ()
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
        self.totalScoreFactor = 1.2;
        self.scorePerLetter = 10;
        self.scoreStyle = ScoreStyle_Exponential;
        self.healthBarToScoreRatio = .75;
    }
    return self;
}

#pragma mark - Getters and Setters


@end
