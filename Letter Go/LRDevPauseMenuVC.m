//
//  LRDevPauseMenuVC.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDevPauseMenuVC.h"
#import "LRDifficultyConstants.h"
#import "LRDifficultyManager.h"
#import "LRIncreaseStyleSelector.h"
#import "LRStatsPageViewController.h"

#define STYLE_NONE          @"None"
#define STYLE_LINEAR        @"Linear"
#define STYLE_EXPONENTIAL   @"Exponential"

@interface LRDevPauseMenuVC  ()
@property NSUInteger numPages;
@property NSDictionary *difficultyDict;
@property NSMutableArray *updatingViews;
@property LRStatsPageViewController *statsVC;
@end

@implementation LRDevPauseMenuVC

@synthesize scrollView;
@synthesize pageControl;
@synthesize pageControlBeingUsed;
@synthesize quitButton;
@synthesize difficultyDict;

#pragma mark - Set Up/Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.numPages = 4;
        self.updatingViews = [NSMutableArray array];
        [self loadDifficultyDictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSubviewValues) name:NOTIFICATION_RESET_DIFFICULTIES object:nil];
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
        frame.origin.x = SCREEN_WIDTH * i;
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

#pragma mark - Page Set Up Functions

- (void) setUpPage:(int)pageNum inView:(UIView*)view
{
    float offset = 20;
    CGRect sliderFrame = CGRectMake(offset, 0, 110, SCREEN_HEIGHT * .7);
    CGRect selectorFrame = CGRectMake(offset, sliderFrame.size.height + 10, 150, SCREEN_HEIGHT * .2);
    if (pageNum == 0) {
        self.statsVC = [[LRStatsPageViewController alloc] init];
        [view addSubview:[self.statsVC view]];
    }
    else if (pageNum == 1) {
        NSArray *healthSliders = @[DV_HEALTHBAR_INITIAL_SPEED, DV_HEALTHBAR_INCREASE_FACTOR, DV_HEALTHBAR_MAX_SPEED, DV_HEALTHBAR_INCREASE_PER_WORD];
        for (int i = 0; i < [healthSliders count]; i++) {
            LRSliderLabelView *slider = [[LRSliderLabelView alloc] initWithFrame:sliderFrame andDictionary:[difficultyDict objectForKey:[healthSliders objectAtIndex:i]]];
            [view addSubview:slider];
            [self.updatingViews addObject:slider];
            sliderFrame.origin.x += sliderFrame.size.width;
        }
        
        NSArray *styleSelectors = @[DV_HEALTHBAR_INCREASE_STYLE];
        for (int i = 0; i < [styleSelectors count]; i++) {
            LRIncreaseStyleSelector *selector = [[LRIncreaseStyleSelector alloc] initWithFrame:selectorFrame andDictionary:[difficultyDict objectForKey:[styleSelectors objectAtIndex:i]]];
            [view addSubview:selector];
            [self.updatingViews addObject:selector];
            selectorFrame.origin.x += selectorFrame.size.width;
        }
    }
    else if (pageNum == 2) {
        sliderFrame.origin.x = offset;
        selectorFrame.origin.x = offset;
        NSArray *scoreSliders = @[DV_SCORE_PER_LETTER, DV_SCORE_WORD_LENGTH_FACTOR, DV_SCORE_INITIAL_LEVEL_PROGRESSION, DV_SCORE_LEVEL_PROGRESS_INCREASE_FACTOR];
        for (int i = 0; i < [scoreSliders count]; i++) {
            LRSliderLabelView *slider = [[LRSliderLabelView alloc] initWithFrame:sliderFrame andDictionary:[difficultyDict objectForKey:[scoreSliders objectAtIndex:i]]];
            [view addSubview:slider];
            [self.updatingViews addObject:slider];
            sliderFrame.origin.x += sliderFrame.size.width;
        }
        NSArray *styleSelectors = @[DV_SCORE_LENGTH_INCREASE_STYLE, DV_SCORE_LEVEL_PROGRESS_INCREASE_STYLE];
        for (int i = 0; i < [styleSelectors count]; i++) {
            LRIncreaseStyleSelector *selector = [[LRIncreaseStyleSelector alloc] initWithFrame:selectorFrame andDictionary:[difficultyDict objectForKey:[styleSelectors objectAtIndex:i]]];
            [view addSubview:selector];
            [self.updatingViews addObject:selector];
            selectorFrame.origin.x += selectorFrame.size.width;
        }
    }
}

- (NSString*)increaseStyleToString:(IncreaseStyle)style {
    if (style == IncreaseStyle_None)        return STYLE_NONE;
    if (style == IncreaseStyle_Linear)      return STYLE_LINEAR;
    if (style == IncreaseStyle_Exponential) return STYLE_EXPONENTIAL;

    NSAssert(0, @"Invalid increase style provided: %i", style);
    return nil;
}

- (IncreaseStyle)stringToIncreaseStyle:(NSString*)string {
    if ([string isEqualToString:STYLE_NONE])           return IncreaseStyle_None;
    if ([string isEqualToString:STYLE_LINEAR])         return IncreaseStyle_Linear;
    if ([string isEqualToString:STYLE_EXPONENTIAL])    return IncreaseStyle_Exponential;
    
    NSAssert(0, @"Invalid increase style title provided: %@", string);
    return -1;
}

#pragma mark - Quit Button/Reload

- (IBAction)quitButtonSelected:(UIButton*)sender{
    [self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STATE_CONTINUE_GAME object:nil];
}

- (void) reloadSubviewValues {
    for (LRDevPauseSubView *subview in self.updatingViews) {
        [subview reloadValue];
    }
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
