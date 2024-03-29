//
//  LRGamePlayLayer.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLayer.h"

#import "LRHealthSection.h"
#import "LRLetterSection.h"
#import "LRButtonSection.h"
#import "LRMainGameSection.h"
#import "LRTopMenuSection.h"
#import "LRShadowRoundedRect.h"

#import "LRButton.h"
#import "LRDevPauseViewController.h"

extern NSString * const kLRGamePlayLayerHealthSectionName;
extern NSString * const kLRGamePlayLayerLetterSectionName;

@interface LRGamePlayLayer : LRLayer

//sections
@property (nonatomic, readonly) LRHealthSection *healthSection;
@property (nonatomic, readonly) LRLetterSection *letterSection;
@property (nonatomic, readonly) LRMainGameSection *mainGameSection;
@property (nonatomic, readonly) LRButtonSection *buttonSection;
@property (nonatomic, readonly) LRTopMenuSection *topMenuSection;

@property (nonatomic, readonly) LRShadowRoundedButton *pauseButton;
@property (nonatomic, readonly) LRDevPauseViewController *devPause;

@end
