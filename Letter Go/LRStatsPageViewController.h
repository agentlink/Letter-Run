//
//  LRStatsPageViewController.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/11/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRStatsPageViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *resetDifficulty;
@property (nonatomic, retain) IBOutlet UIButton *startNewGameButton;

@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;
@property (nonatomic, retain) IBOutlet UILabel *nextScoreLabel;

@property (nonatomic, retain) IBOutlet UISwitch *mailmanDamage;
@property (nonatomic, retain) IBOutlet UISwitch *healthBarDrops;

@property (nonatomic, retain) IBOutlet UIStepper *levelStepper;
@property (nonatomic, retain) IBOutlet UIStepper *healthStepper;

@property (nonatomic, retain) IBOutlet UILabel *wordScoreLabel;

@property (nonatomic, retain) IBOutlet UITextField *forceSubmitField;
@end
