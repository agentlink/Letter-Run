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
        
        self.intialLetterDropPeriod = 2.5;
        self.letterDropPeriodDecreaseRate = 1.2;
        self.letterDropDecreaseStyle = IncreaseStyle_Exponential;
        self.minimumDropPeriod = .7;
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

#pragma mark - Letter Drop Rate
- (CGFloat) letterDropPeriod {
    float dropPeriod = self.intialLetterDropPeriod;
    for (int i = 1; i < self.level; i++) {
        if (self.letterDropDecreaseStyle == IncreaseStyle_Linear) {
            dropPeriod-= self.letterDropPeriodDecreaseRate;
        }
        else if (self.letterDropPeriodDecreaseRate == IncreaseStyle_Exponential) {
            dropPeriod/= self.letterDropPeriodDecreaseRate;
        }
    }
    if (self.minimumDropPeriod > dropPeriod)
        return self.minimumDropPeriod;
    return self.intialLetterDropPeriod;
}

@end
