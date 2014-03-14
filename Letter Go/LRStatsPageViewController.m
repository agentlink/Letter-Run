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
#import "LRDictionaryChecker.h"

@interface LRStatsPageViewController ()  <UITextFieldDelegate>
@end

@implementation LRStatsPageViewController

@synthesize levelLabel, healthLabel, scoreLabel, nextScoreLabel;
@synthesize healthBarDrops, mailmanDamage;
@synthesize healthStepper, levelStepper;
@synthesize wordScoreLabel;
@synthesize forceSubmitField;

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
- (void)loadLabelText
{
    levelLabel.text = [NSString stringWithFormat:@"%i", [[LRDifficultyManager shared] level]];
    scoreLabel.text = [NSString stringWithFormat:@"%i", [[LRScoreManager shared] score]];
    nextScoreLabel.text = [NSString stringWithFormat:@"%i", [[LRScoreManager shared] scoreToNextLevel]];
    //Make there only one fraction digit
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setMaximumFractionDigits:1];
    NSNumber *health = [NSNumber numberWithFloat:[[self _healthSection] percentHealth]];

    healthLabel.text = [NSString stringWithFormat:@"%@%@", [nf stringFromNumber: health], @"%"];
    [self loadWordScores];
}

- (void)loadWordScores
{
    int numShownWords = 3;
    wordScoreLabel.text = @"";
    wordScoreLabel.numberOfLines = 0;
    
    NSMutableString *labelText = [[NSMutableString alloc] init];
    NSArray *submittedWords = [[LRScoreManager shared] submittedWords];
    if ([submittedWords count] > numShownWords)
        submittedWords = [submittedWords subarrayWithRange:(NSRange){submittedWords.count - numShownWords, numShownWords}];
    for (int i = (int)[submittedWords count] - 1; i >= 0; i--)
    {
        NSString *word = [[submittedWords objectAtIndex:i] objectForKey:@"word"];
        int wordScore = (int)[[[submittedWords objectAtIndex:i] objectForKey:@"score"] integerValue];
        [labelText appendFormat:@"%@: %i\n", word, wordScore];
    }
    wordScoreLabel.text = labelText;
}

#pragma mark - Steppers
- (void)loadSteppers
{
    levelStepper.value = [[LRDifficultyManager shared] level];
    levelStepper.minimumValue = 1;
    levelStepper.maximumValue = 100;
    levelStepper.stepValue = 1;
    
    healthStepper.value = [[self _healthSection] percentHealth];
    healthStepper.minimumValue = 0.0;
    healthStepper.maximumValue = 100.0;
    healthStepper.stepValue = 10;
}

- (IBAction) levelChanged:(UIStepper *)sender {
    [[LRDifficultyManager shared] setLevel:(int)sender.value];
    [self reloadValues];
}

- (IBAction)healthChanged:(UIStepper *)sender
{
    float healthDiff = sender.value - [[self _healthSection] percentHealth];
    [[self _healthSection] moveHealthByPercent:healthDiff];
    [self reloadValues];

}

- (LRHealthSection *)_healthSection
{
    return [[[[LRGameStateManager shared] gameScene] gamePlayLayer] healthSection];
}

#pragma mark - Switches
- (void)loadSwitchValues
{
    [self.mailmanDamage setOn:[[LRDifficultyManager shared] mailmanReceivesDamage]];
    [self.healthBarDrops setOn:[[LRDifficultyManager shared] healthBarFalls]];
}

- (IBAction)mailmanDamageSwitched:(id)sender {
    [[LRDifficultyManager shared] setMailmanReceivesDamage:[(UISwitch *)sender isOn]];
}

- (IBAction)healthDropsSwitched:(id)sender {
    [[LRDifficultyManager shared] setHealthBarFalls:[(UISwitch *)sender isOn]];
}

#pragma mark - Buttons
- (IBAction) resetLevelButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RESET_DIFFICULTIES object:nil];
}

- (IBAction) newGame:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"devpause"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_GAME_OVER object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_NEW_GAME object:nil userInfo:userInfo];
    [self reloadValues];
}

- (void)reloadValues {
    [self loadSteppers];
    [self loadLabelText];
    [self loadSwitchValues];
    [self loadTextFields];
    return;
}

#pragma mark - Text Fields

- (void)loadTextFields
{
    forceSubmitField.keyboardType = UIKeyboardTypeNamePhonePad;
    forceSubmitField.returnKeyType = UIReturnKeyDone;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)forceSubmitWord:(UITextField *)sender
{
    NSString *inputWord = [sender.text uppercaseString];
    sender.text = @"";
    if (![inputWord length])
        return;
    
    //Clean up input by removing non alphabet letters and space
    NSMutableCharacterSet *legitCharacters = [NSMutableCharacterSet uppercaseLetterCharacterSet];
    [legitCharacters addCharactersInString:@" "];
    NSCharacterSet *charactersToRemove = [legitCharacters invertedSet];
    NSString *cleanInput = [[inputWord componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    
    //Load words into a list and remove those with too many or too few letters.
    //For the rest, post the submit word notification via forcedWord
    NSMutableArray *inputWords = [NSMutableArray arrayWithArray:[cleanInput componentsSeparatedByString:@" "]];
    NSMutableArray *wordsToRemove = [NSMutableArray array];
    for (NSString *word in inputWords) {
        if ([word length] < kWordMinimumLetterCount || [word length] > kWordMaximumLetterCount) {
            NSLog(@"Warning: '%@' is either too long or too short to submit.", word);
            [wordsToRemove addObject:word];
        }
        else {
            if (![[LRDictionaryChecker shared] checkForWordInDictionary:word])
                NSLog(@"Warning: %@ does not appear in the dictionary.", word);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SUBMIT_WORD object:Nil userInfo:[NSDictionary dictionaryWithObject:word forKey:@"forcedWord"]];
        }
    }
    [self reloadValues];
}

- (void)addSubviews {
    [self.view addSubview:self.resetDifficulty];
    [self.view addSubview:self.startNewGameButton];
    
    [self.view addSubview:levelLabel];
    [self.view addSubview:scoreLabel];
    [self.view addSubview:healthLabel];
    [self.view addSubview:nextScoreLabel];
    [self.view addSubview:wordScoreLabel];

    [self.view addSubview:mailmanDamage];
    [self.view addSubview:healthBarDrops];
    
    [self.view addSubview:healthStepper];
    [self.view addSubview:levelStepper];
    
    [self.view addSubview:forceSubmitField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
