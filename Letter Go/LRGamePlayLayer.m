//
//  LRGamePlayLayer.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGamePlayLayer.h"
#import "LRLetterBlockBuilder.h"
#import "LRGameStateManager.h"
#import "LRRowManager.h"
#import "LRPositionConstants.h"

NSString * const kLRGamePlayLayerHealthSectionName = @"healthSection";
NSString * const kLRGamePlayLayerLetterSectionName = @"letterSection";


@interface LRGamePlayLayer ()
@property LRRowManager *letterSlots;

@property (nonatomic, strong) LRHealthSection *healthSection;
@property (nonatomic, strong) LRLetterSection *letterSection;
@property (nonatomic, strong) LRMainGameSection *mainGameSection;
@property (nonatomic, strong) LRButtonSection *buttonSection;
@property (nonatomic, strong) LRTopMenuSection *topMenuSection;

@property (nonatomic, strong) LRDevPauseViewController *devPause;

@end

@implementation LRGamePlayLayer

#pragma mark - Set Up/Initialization

- (id) init
{
    if (self = [super init])
    {
        [self setSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self setPosition:CGPointMake(self.size.width/2, self.size.height/2)];
        [self setUserInteractionEnabled:YES];
        
        self.color = [UIColor gamePlayLayerBackgroundColor];
        [self createLayerContent];
        LRMovingBlockBuilder *envBuilder = [LRMovingBlockBuilder new];
        self.mainGameSection.envelopeBuilder = envBuilder;
        envBuilder.letterAdditionDelegate = self.letterSection;        
    }

    return self;
}


- (void)createLayerContent
{
    [self addChild:self.buttonSection];
    [self addChild:self.healthSection];
    [self addChild:self.letterSection];
    [self addChild:self.mainGameSection];
    [self addChild:self.topMenuSection];
}

#pragma mark - Layer Content Set Up -
#pragma mark Sections
- (LRHealthSection *)healthSection
{
    if (!_healthSection) {
        CGFloat healthSectionYPos = -self.size.height/2 + kSectionHeightLetterSection + kSectionHeightButtonSection + kSectionHeightMainSection + kSectionHeightHealthSection/2;
        _healthSection = [[LRHealthSection alloc] initWithSize:CGSizeMake(self.size.width, kSectionHeightHealthSection)];
        _healthSection.position = CGPointMake(0, healthSectionYPos);
        _healthSection.zPosition = zPos_HealthSection;
        _healthSection.name = kLRGamePlayLayerHealthSectionName;
    }
    return _healthSection;
}

- (LRLetterSection *)letterSection
{
    if (!_letterSection) {
        _letterSection = [[LRLetterSection alloc] initWithSize:CGSizeMake(self.size.width, kSectionHeightLetterSection)];
        _letterSection.position = CGPointMake(self.position.x - self.size.width/2,
                                              0 - self.size.height/2 + self.letterSection.size.height/2 + kSectionHeightButtonSection);
        _letterSection.zPosition = zPos_LetterSection;
        _letterSection.name = kLRGamePlayLayerLetterSectionName;
    }
    return _letterSection;
}

- (LRMainGameSection *)mainGameSection {
    if (!_mainGameSection) {
        CGFloat mainGameSectionXPos = 0;
        CGFloat mainGameSectionYPos = -self.size.height/2 + kSectionHeightLetterSection + kSectionHeightButtonSection + kSectionHeightMainSection/2;
        
        _mainGameSection = [[LRMainGameSection alloc] initWithSize:CGSizeMake(SCREEN_WIDTH, kSectionHeightMainSection)];
        _mainGameSection.position = CGPointMake(mainGameSectionXPos, mainGameSectionYPos);
        _mainGameSection.zPosition = zPos_MainGameSection;
        _mainGameSection.color = [UIColor clearColor];
    }
    return _mainGameSection;
}

- (LRButtonSection *)buttonSection
{
    if (!_buttonSection) {
        CGFloat buttonSectionXPos = 0;
        CGFloat buttonSectionYPos = -self.size.height/2 + kSectionHeightButtonSection/2;
        _buttonSection = [[LRButtonSection alloc] initWithSize:CGSizeMake(SCREEN_WIDTH, kSectionHeightButtonSection)];
        _buttonSection.position = CGPointMake(buttonSectionXPos, buttonSectionYPos);
        _buttonSection.zPosition = zPos_ButtonSection;
    }
    return _buttonSection;
}

- (LRTopMenuSection *)topMenuSection
{
    if (!_topMenuSection) {
        CGFloat topMenuXPos = 0;
        CGFloat topmenuYPos = SCREEN_HEIGHT/2 - kSectionHeightTopMenuSection/2;
        _topMenuSection = [[LRTopMenuSection alloc]initWithSize:CGSizeMake(SCREEN_WIDTH, kSectionHeightTopMenuSection)];
        _topMenuSection.position = CGPointMake(topMenuXPos, topmenuYPos);
    }
    return _topMenuSection;
}

#pragma mark - LRGameUpdateDelegate
- (void)gameStateNewGame
{
    self.pauseButton.isEnabled = YES;
}

- (void)gameStateGameOver
{
    self.pauseButton.isEnabled = NO;
}

@end