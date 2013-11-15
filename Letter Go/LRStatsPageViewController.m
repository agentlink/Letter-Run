//
//  LRStatsPageViewController.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/11/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRStatsPageViewController.h"
#import "LRDevPauseSubView.h"
#import "LRConstants.h"
#import "LRDifficultyManager.h"
#import "LRScoreManager.h"
#import "LRGameStateManager.h"

@interface LRStatsPageViewController ()
@end

@implementation LRStatsPageViewController

@synthesize levelLabel, healthLabel, scoreLabel;
@synthesize healthBarDrops, mailmanDamage;
@synthesize healthStepper, levelStepper;
@synthesize wordScoreLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadValues];
    [self addSubviews];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Labels
- (void) loadLabelText
{
    self.levelLabel.text = [NSString stringWithFormat:@"%i", [[LRDifficultyManager shared] level]];
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", [[LRScoreManager shared] score]];
    
    //Make there only one fraction digit
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setMaximumFractionDigits:1];
    NSNumber *health = [NSNumber numberWithFloat:[[LRGameStateManager shared] percentHealth]];

    self.healthLabel.text = [NSString stringWithFormat:@"%@%@", [nf stringFromNumber: health], @"%"];
    [self loadWordScores];
}

- (void) loadWordScores
{
    int numShownWords = 3;
    wordScoreLabel.text = @"";
    wordScoreLabel.numberOfLines = 0;
    
    NSMutableString *labelText = [[NSMutableString alloc] init];
    NSArray *submittedWords = [[LRScoreManager shared] submittedWords];
    if ([submittedWords count] > numShownWords)
        submittedWords = [submittedWords subarrayWithRange:(NSRange){submittedWords.count - numShownWords, numShownWords}];
    for (int i = [submittedWords count] - 1; i >= 0; i--)
    {
        NSString *word = [submittedWords objectAtIndex:i];
        int wordScore = [LRScoreManager scoreForWord:word];
        [labelText appendFormat:@"%@: %i\n", word, wordScore];
    }
    wordScoreLabel.text = labelText;
}

#pragma mark - Steppers
- (void) loadSteppers
{
    levelStepper.value = [[LRDifficultyManager shared] level];
    levelStepper.minimumValue = 1;
    levelStepper.maximumValue = 100;
    levelStepper.stepValue = 1;
    
    healthStepper.value = [[LRGameStateManager shared] percentHealth];
    healthStepper.minimumValue = 0.0;
    healthStepper.maximumValue = 100.0;
    healthStepper.stepValue = 10;
}

- (IBAction) levelChanged:(UIStepper*)sender {
    [[LRDifficultyManager shared] setLevel:(int)sender.value];
    [self reloadValues];
}

- (IBAction)healthChanged:(UIStepper*)sender
{
    float healthDiff = sender.value - [[LRGameStateManager shared] percentHealth];
    [[LRGameStateManager shared] moveHealthByPercent:healthDiff];
    [self reloadValues];

}
#pragma mark - Switches
- (void) loadSwitchValues
{
    [self.mailmanDamage setOn:[[LRDifficultyManager shared] mailmanReceivesDamage]];
    [self.healthBarDrops setOn:[[LRDifficultyManager shared] healthBarFalls]];
}

- (IBAction)mailmanDamageSwitched:(id)sender {
    [[LRDifficultyManager shared] setMailmanReceivesDamage:[(UISwitch*)sender isOn]];
}

- (IBAction)healthDropsSwitched:(id)sender {
    [[LRDifficultyManager shared] setHealthBarFalls:[(UISwitch*)sender isOn]];
}

#pragma mark - Buttons
- (IBAction) resetLevelButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RESET_DIFFICULTIES object:nil];
}

- (IBAction) newGame:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"devpause"];
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_NEW_GAME object:nil userInfo:userInfo];
    [self reloadValues];
}

- (void) reloadValues {
    [self loadSteppers];
    [self loadLabelText];
    [self loadSwitchValues];
    return;
}

- (void) addSubviews {
    [self.view addSubview:self.resetDifficulty];
    [self.view addSubview:self.startNewGameButton];
    
    [self.view addSubview:levelLabel];
    [self.view addSubview:scoreLabel];
    [self.view addSubview:healthLabel];

    [self.view addSubview:mailmanDamage];
    [self.view addSubview:healthBarDrops];
    
    [self.view addSubview:healthStepper];
    [self.view addSubview:levelStepper];
    
    [self.view addSubview:wordScoreLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
