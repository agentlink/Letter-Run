//
//  LRSliderLabelView.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRSliderLabelView : UIView <UITextFieldDelegate> {
    UISlider *slider;
    UITextField *textField;
    UILabel *variableTitle;
}

@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UILabel *variableTitle;

@end
