//
//  LRDevPauseMenuVC.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRSliderLabelView.h"

@interface LRDevPauseMenuVC : UIViewController <UIScrollViewDelegate> {
    UIScrollView *scrollView;
    UIPageControl* pageControl;
    LRSliderLabelView *healthBarSpeedSlider;
    UIButton *quitButton;
    
    BOOL pageControlBeingUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIButton *quitButton;
@property (nonatomic, retain) LRSliderLabelView *healthBarSpeedSlider;

@property BOOL pageControlBeingUsed;

- (IBAction)changePage;

@end
