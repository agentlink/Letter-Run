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
#import "LRButton.h"
#import "LRDevPauseMenuVC.h"
#import "LRDevPauseViewController.h"
@interface LRGamePlayLayer : LRLayer

@property (nonatomic, strong) LRHealthSection *healthSection;
@property (nonatomic, strong) LRLetterSection *letterSection;
@property (nonatomic, strong) LRMainGameSection *mainGameSection;
@property (nonatomic, strong) LRButtonSection *buttonSection;

@property (nonatomic, strong) LRButton *pauseButton;

@property (nonatomic, strong) LRDevPauseViewController *devPause;

@end
