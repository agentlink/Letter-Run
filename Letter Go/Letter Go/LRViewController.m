//
//  LRViewController.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRViewController.h"
#import "LRGameScene.h"
#import "LRSharedTextureCache.h"

@implementation LRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.backgroundColor = [UIColor blackColor];
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    [skView setMultipleTouchEnabled:NO];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    
    //[resent an all black scene to get rid of the gray color
    SKScene *blackScene = [SKScene new];
    blackScene.paused = YES;
    blackScene.backgroundColor = [UIColor blackColor];
    [skView presentScene:blackScene];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    SKView * skView = (SKView *)self.view;
    // Create and configure the scene.
    LRGameScene * scene = [LRGameScene scene];
    // Present the scene.
    [[LRSharedTextureCache shared] preloadTextureAtlasesWithCompletion:^{
        [skView presentScene:scene];
    }];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
