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
    [UIView animateWithDuration:.4 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:.5 alpha:.7];
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
