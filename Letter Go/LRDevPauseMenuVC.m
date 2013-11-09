//
//  LRDevPauseMenuVC.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDevPauseMenuVC.h"
#import "LRDifficultyConstants.h"

@interface LRDevPauseMenuVC  ()
@property NSUInteger numPages;
@property NSDictionary *difficultyDict;
@end

@implementation LRDevPauseMenuVC

@synthesize scrollView;
@synthesize pageControl;
@synthesize pageControlBeingUsed;
@synthesize healthBarSpeedSlider;
@synthesize quitButton;
@synthesize difficultyDict;

#pragma mark - Set Up/Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.numPages = 4;
        [self loadDifficultyDictionary];
    }
    return self;
}

- (void) loadDifficultyDictionary
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DifficultyVariables" ofType:@"plist"];
    difficultyDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    //Scroll View
    for (int i = 0; i < self.numPages; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        [self setUpPage:i inView:subview];
        [self.scrollView addSubview:subview];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.numPages, self.scrollView.frame.size.height);
    self.scrollView.delegate = self;
    self.scrollView.delaysContentTouches = NO;
    
    //Page Control
    self.pageControl.numberOfPages = self.numPages;

    [self.view addSubview:quitButton];
}

- (void) setUpPage:(int)pageNum inView:(UIView*)view
{
    if (pageNum == 0) {
        //Score per letter
        CGRect frame = CGRectMake(34, 0, 120, SCREEN_HEIGHT * .8);
        healthBarSpeedSlider = [[LRSliderLabelView alloc] initWithFrame:frame andDictionary:[difficultyDict objectForKey:DV_INTIAL_HEALTH_BAR_SPEED]];
        [view addSubview:healthBarSpeedSlider];
    }
}

#pragma mark - Quit Button

- (IBAction)quitButtonSelected:(UIButton*)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_CONTINUE_GAME object:nil];
    [self.view removeFromSuperview];
}

#pragma mark - Scroll View Functions

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    self.pageControlBeingUsed = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControlBeingUsed = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
