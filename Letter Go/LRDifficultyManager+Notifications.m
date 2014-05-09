//
//  LRDifficultyManager+Notifications.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/9/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDifficultyManager+Notifications.h"

#define KEY_TYPE            @"type"
#define KEY_VALUE           @"initialValue"

#define INT_TYPE            @"int"
#define FLOAT_TYPE          @"float"
#define OBJECT_TYPE         @"object"

@implementation LRDifficultyManager (Notifications)

- (void)resetUserDefaults
{
    [self writeUserDefaults];
    [self loadNotifications];
}

- (void)writeUserDefaults
{
    for (NSArray *section in [self.difficultyDict allValues]) {
        for (NSDictionary *diffVar in section) {
            NSString *userDefaultKey = [diffVar objectForKey:USER_DEFAULT_KEY];
            NSString *varType = [diffVar objectForKey:KEY_TYPE];
            if ([varType isEqualToString:INT_TYPE]) {
                [[NSUserDefaults standardUserDefaults] setInteger:[[diffVar objectForKey:KEY_VALUE] integerValue] forKey:userDefaultKey];
            }
            else if ([varType isEqualToString:FLOAT_TYPE]) {
                [[NSUserDefaults standardUserDefaults] setFloat:[[diffVar objectForKey:KEY_VALUE] floatValue] forKey:userDefaultKey];
            }
            else if ([varType isEqualToString:OBJECT_TYPE]) {
                [[NSUserDefaults standardUserDefaults] setObject:[diffVar objectForKey:KEY_VALUE] forKey:userDefaultKey];
            }
        }
    }
    
    //This is a dummy NSUserDefault. This makes sure that all the other ones have loaded (thus, it's last)
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:TRUE] forKey:USER_DEFAULTS_LOADED];
}

- (void)loadNotifications
{
    for (NSArray *section in [self.difficultyDict allValues])
        for (NSDictionary *diffVar in section)
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateValue:) name:[diffVar objectForKey:USER_DEFAULT_KEY] object:nil];
    
    //Check for resetting all difficulty values
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUserDefaults) name:NOTIFICATION_RESET_DIFFICULTIES object:nil];
}

- (void)loadUnsavedValues
{
    self.mailmanReceivesDamage = YES;
    self.healthBarFalls = YES;
    self.lettersFallVertically = NO;
    
    self.healthInEnvelopes = 40.0;
    self.QuEnabled = YES;
}

- (void)loadUserDefaults
{
    //Health
    self.initialHealthDropTime = 30;//[[NSUserDefaults standardUserDefaults] floatForKey:DV_HEALTHBAR_INITIAL_SPEED];
    self.healthSpeedIncreaseFactor = [[NSUserDefaults standardUserDefaults] floatForKey:DV_HEALTHBAR_INCREASE_FACTOR];
    self.healthBarMinDropTime = [[NSUserDefaults standardUserDefaults] floatForKey:DV_HEALTHBAR_MAX_SPEED];
    self.healthPercentIncreasePer100Pts = [[NSUserDefaults standardUserDefaults] floatForKey:DV_HEALTHBAR_INCREASE_PER_WORD];
    
    //Mailman + Love Letters
    self.mailmanHitDamage = [[NSUserDefaults standardUserDefaults] floatForKey:DV_MAILMAN_LETTER_DAMAGE];
    self.loveLetterMultiplier = [[NSUserDefaults standardUserDefaults] integerForKey:DV_MAILMAN_LOVE_BONUS];
    self.percentLoveLetters = [[NSUserDefaults standardUserDefaults] integerForKey:DV_MAILMAN_LOVE_PERCENT];
    self.flingLetterSpeed = [[NSUserDefaults standardUserDefaults] floatForKey:DV_MAILMAN_FLING_SPEED];
    
    //Letter Generation
    self.maxNumber_consonants = [[NSUserDefaults standardUserDefaults] integerForKey:DV_GENERATION_MAX_CONSONANTS];
    self.maxNumber_vowels = [[NSUserDefaults standardUserDefaults] integerForKey:DV_GENERATION_MAX_VOWELS];
    self.maxNumber_sameLetters = [[NSUserDefaults standardUserDefaults] integerForKey:DV_GENERATION_MAX_LETTERS];
    
    //Parallax
    self.parallaxLayerSpeeds = [[NSUserDefaults standardUserDefaults] objectForKey:DV_PARALLAX_SPEED_ARRAY];
    self.baseParallaxPixelsPerSecond = [[NSUserDefaults standardUserDefaults] floatForKey:DV_PARALLAX_BASE_SPEED];
    self.scrollingSpeedIncrease = [[NSUserDefaults standardUserDefaults] floatForKey:DV_PARALLAX_SPEED_INCREASE];
}

- (void)updateValue:(NSNotification *)notification
{
    NSString *noteName = notification.name;
    NSString *typeName = [notification.userInfo objectForKey:KEY_TYPE];
    if ([typeName isEqualToString:INT_TYPE]) {
        NSInteger value = [[[notification userInfo] objectForKey:noteName] integerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:value forKey:noteName];
    }
    else if ([typeName isEqualToString:FLOAT_TYPE]) {
        CGFloat value = [[[notification userInfo] objectForKey:noteName] floatValue];
        [[NSUserDefaults standardUserDefaults] setFloat:value forKey:noteName];

    }
    else if ([typeName isEqualToString:OBJECT_TYPE]) {
        NSObject *value = [[notification userInfo] objectForKey:noteName];
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:noteName];
    }
        
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadUserDefaults];
}

- (void)setUserDefaults
{
    //Health
    [[NSUserDefaults standardUserDefaults] setFloat:self.initialHealthDropTime forKey:DV_HEALTHBAR_INITIAL_SPEED];
    [[NSUserDefaults standardUserDefaults] setFloat:self.healthSpeedIncreaseFactor forKey:DV_HEALTHBAR_INCREASE_FACTOR];
    [[NSUserDefaults standardUserDefaults] setFloat:self.healthBarMinDropTime forKey:DV_HEALTHBAR_MAX_SPEED];
    [[NSUserDefaults standardUserDefaults] setFloat:self.healthPercentIncreasePer100Pts forKey:DV_HEALTHBAR_INCREASE_PER_WORD];
    
    //Mailman + Love Letters
    [[NSUserDefaults standardUserDefaults] setFloat:self.mailmanHitDamage forKey:DV_MAILMAN_LETTER_DAMAGE];
    [[NSUserDefaults standardUserDefaults] setInteger:self.loveLetterMultiplier forKey:DV_MAILMAN_LOVE_BONUS];
    [[NSUserDefaults standardUserDefaults] setInteger:self.percentLoveLetters forKey:DV_MAILMAN_LOVE_PERCENT];
    [[NSUserDefaults standardUserDefaults] setFloat:self.flingLetterSpeed forKey:DV_MAILMAN_FLING_SPEED];
    
    //Letter Generation
    [[NSUserDefaults standardUserDefaults] setInteger:self.maxNumber_consonants forKey:DV_GENERATION_MAX_CONSONANTS];
    [[NSUserDefaults standardUserDefaults] setInteger:self.maxNumber_vowels forKey:DV_GENERATION_MAX_VOWELS];
    [[NSUserDefaults standardUserDefaults] setInteger:self.maxNumber_sameLetters forKey:DV_GENERATION_MAX_LETTERS];
    
    //Parallax Speeds
    [[NSUserDefaults standardUserDefaults] setObject:self.parallaxLayerSpeeds forKey:DV_PARALLAX_SPEED_ARRAY];
    [[NSUserDefaults standardUserDefaults] setFloat:self.baseParallaxPixelsPerSecond forKey:DV_PARALLAX_BASE_SPEED];
    [[NSUserDefaults standardUserDefaults] setFloat:self.scrollingSpeedIncrease forKey:DV_PARALLAX_SPEED_INCREASE];
}



@end
