//
//  LRDifficultyManager+Notifications.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/9/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDifficultyManager.h"

@interface LRDifficultyManager (Notifications)

- (void)writeUserDefaults;
- (void)loadUserDefaults;
- (void)setUserDefaults;

- (void)loadNotifications;
- (void)loadUnsavedValues;

@end
