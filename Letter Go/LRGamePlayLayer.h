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
#import "LRMailman.h"
#import "LRButton.h"
#import "LRDevPauseMenuVC.h"

@interface LRGamePlayLayer : LRLayer

@property LRHealthSection *healthSection;
@property LRLetterSection *letterSection;
@property LRMailman *mailman;
@property LRButton *pauseButton;

@property (nonatomic, strong) LRDevPauseMenuVC *devPause;

- (void) dropInitialLetters;
- (CGPoint) flungEnvelopeDestination;
@end
