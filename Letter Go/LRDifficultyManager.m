//
//  LRDifficultyManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/15/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDifficultyManager.h"
#import "LRDifficultyManager+Notifications.h"

@interface LRDifficultyManager ()
@end

@implementation LRDifficultyManager

# pragma mark - Init Functions
static LRDifficultyManager *_shared = nil;
+ (LRDifficultyManager *)shared
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
        [self loadDifficultyInfo];
        //Check to see if NSUserDefaults have been loaded
        if (![[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_LOADED]) {
            [self writeUserDefaults];
        }
        [self loadNotifications];
        [self loadUserDefaults];
        [self loadUnsavedValues];
    }
    return self;
}

- (void)loadDifficultyInfo
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DifficultyVariables" ofType:@"plist"];
    self.difficultyDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

#pragma mark - Speed Factor Calculators

- (CGFloat) healthBarDropTime
{
    //Unit: letters allowed to drop without a response
    CGFloat healthSpeed = self.healthInEnvelopes;

    if (healthSpeed < self.healthBarMinDropTime)
        return self.healthBarMinDropTime;
    return healthSpeed;
}

@end
