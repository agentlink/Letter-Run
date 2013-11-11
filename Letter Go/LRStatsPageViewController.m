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

@interface LRStatsPageViewController ()

@end

@implementation LRStatsPageViewController

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
    [self.view addSubview:self.resetDifficulty];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) resetLevelButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RESET_DIFFICULTIES object:nil];
}

- (void) reloadValue {
    return;
}

@end
