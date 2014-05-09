//
//  LRDifficultyManager.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/15/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGameStateDelegate.h"
#import "LRDifficultyConstants.h"

typedef NS_ENUM(NSInteger, IncreaseStyle)  {
    IncreaseStyle_None,
    IncreaseStyle_Linear,
    IncreaseStyle_Exponential
};


@interface LRDifficultyManager : SKSpriteNode <LRGameStateDelegate>

+ (LRDifficultyManager *)shared;

- (CGFloat) healthBarDropTime;

@property NSDictionary *difficultyDict;

#pragma mark - Health Bar Properties
@property CGFloat healthPercentIncreasePer100Pts;
@property CGFloat initialHealthDropTime;
@property CGFloat healthSpeedIncreaseFactor;
@property CGFloat healthBarMinDropTime;
//Not saved
@property CGFloat healthInEnvelopes;


#pragma mark - Mailman/Love Letter Properties
@property CGFloat mailmanHitDamage;
@property NSInteger loveLetterMultiplier;
@property NSInteger percentLoveLetters;
@property CGFloat flingLetterSpeed;

#pragma mark - Letter Generation Properties
@property NSInteger maxNumber_consonants;
@property NSInteger maxNumber_vowels;
@property NSInteger maxNumber_sameLetters;
//Not saved
@property BOOL QuEnabled;

#pragma mark - Parallax Properties
@property CGFloat baseParallaxPixelsPerSecond;
@property CGFloat scrollingSpeedIncrease;
@property NSArray *parallaxLayerSpeeds;

#pragma mark - Damage Functions
//Not saved to NSUserDefaults
@property BOOL mailmanReceivesDamage;
@property BOOL healthBarFalls;
@property BOOL mailmanScreenSide;
@property BOOL lettersFallVertically;
@end
