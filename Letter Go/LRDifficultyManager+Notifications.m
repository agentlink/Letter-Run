//
//  LRDifficultyManager+Notifications.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/9/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDifficultyManager+Notifications.h"

@implementation LRDifficultyManager (Notifications)

- (void) loadNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runInitialLoad) name:NOTIFICATION_RESET_DIFFICULTIES object:nil];
    
    NSArray *general_floats = @[DV_HEALTHBAR_INCREASE_FACTOR, DV_HEALTHBAR_INITIAL_SPEED, DV_HEALTHBAR_MAX_SPEED];
    for (NSString *notificationName in general_floats) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generalUpdateValue_float:) name:notificationName object:nil];
    }
    NSArray *general_increase = @[DV_HEALTHBAR_INCREASE_STYLE];
    for (NSString *notificationName in general_increase) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generalUpdateValue_increase:) name:notificationName object:nil];
    }
}


- (void) generalUpdateValue_float:(NSNotification*)notification
{
    NSString *noteName = notification.name;
    CGFloat value = [[[notification userInfo] objectForKey:noteName] floatValue];
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:noteName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadUserDefaults];

}

- (void) generalUpdateValue_increase:(NSNotification*)notification
{
    NSString *noteName = notification.name;
    IncreaseStyle value = [[[notification userInfo] objectForKey:noteName] integerValue];
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:noteName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadUserDefaults];
}

@end
