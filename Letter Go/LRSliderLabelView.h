//
//  LRSliderLabelView.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDevPauseSubView.h"

@interface LRSliderLabelView : LRDevPauseSubView <UITextFieldDelegate> {
    UISlider *slider;
    UITextField *textField;
    UILabel *variableTitle;
    UIButton *resetButton;
}

@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UILabel *variableTitle;
@property (nonatomic, retain) UIButton *resetButton;

@end
