//
//  LRDevPauseViewController.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 4/20/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRDevPauseViewController.h"
#import "LRGameStateManager.h"

@interface LRDevPauseViewController ()
@end

@implementation LRDevPauseViewController
{
    UIButton *_newGameButton;
    UISwitch *_healthBarDropsSwitch;
}

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

    //Animate its appearance
    self.view.backgroundColor = [UIColor clearColor];
    _newGameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    
    _newGameButton.translatesAutoresizingMaskIntoConstraints = NO;
    _newGameButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [_newGameButton setContentEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5)];
    [[_newGameButton layer] setCornerRadius:8.0f];
    [[_newGameButton layer] setMasksToBounds:YES];
    [[_newGameButton layer] setBorderWidth:1.0f];
    [[_newGameButton layer] setBorderColor:[UIColor grayColor].CGColor];
    [_newGameButton setTitle:@"Restart?" forState:UIControlStateNormal];
    [_newGameButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_newGameButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    
    [_newGameButton addTarget:self action:@selector(_restartGame) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_newGameButton];
    
    NSDictionary *metrics = @{};
    NSDictionary *views = NSDictionaryOfVariableBindings(_newGameButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[_newGameButton]"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[_newGameButton]"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:views]];


    
}

- (void)viewWillAppear:(BOOL)animated
{
    [UIView animateWithDuration:.4 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.7];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_restartGame
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"devpause"];
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_GAME_OVER object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_NEW_GAME object:nil userInfo:userInfo];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
