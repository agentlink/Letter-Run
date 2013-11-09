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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generalUpdateValue:) name:DV_INTIAL_HEALTH_BAR_SPEED object:nil];
}


- (void) generalUpdateValue:(NSNotification*)notification
{
    NSString *noteName = notification.name;
    CGFloat value = [[[notification userInfo] objectForKey:noteName] floatValue];
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:noteName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadUserDefaults];

}

@end
