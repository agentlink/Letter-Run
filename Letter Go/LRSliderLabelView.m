//
//  LRSliderLabelView.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRSliderLabelView.h"
#import "LRConstants.h"
@implementation LRSliderLabelView
@synthesize slider, textField, variableTitle;
- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createContent];
    }
    return self;
}

- (void) createContent
{
    [self setUpTitle];
    [self setUpSlider];
    [self setUpTextField];
   // [self debug_colors];
}

- (void) setUpSlider
{
    slider = [[UISlider alloc] init];
    CGAffineTransform rotate90 = CGAffineTransformMakeRotation(M_PI * -0.5);
    slider.transform = rotate90;
    
    CGFloat slideWidth = self.frame.size.width;
    CGFloat slideHeight = self.frame.size.height * .7;
    CGRect slideFrame = CGRectMake(0, self.frame.size.height - slideHeight, slideWidth, slideHeight);
    slider.frame = slideFrame;
    
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
}

- (void) setUpTextField
{
    CGFloat textWidth = self.frame.size.width/2;
    CGFloat textHeight = self.frame.size.width/4;
    textField = [[UITextField alloc] initWithFrame:CGRectMake((self.frame.size.width - textWidth)/2, variableTitle.frame.size.height, textWidth, textHeight)];
    
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont systemFontOfSize:15];
    textField.placeholder = [NSString stringWithFormat:@"%@", [self formattedFloat:slider.value]];
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    
    [self addSubview:textField];
    
    //Set up keyboard
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_HEIGHT, 35.0f)];
    toolbar.barStyle=UIBarStyleBlackOpaque;
    // Create a flexible space to align buttons to the right
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    // Create a cancel button to dismiss the keyboard
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resetView)];
    // Add buttons to the toolbar
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, barButtonItem, nil]];
    // Set the toolbar as accessory view of an UITextField object
    textField.inputAccessoryView = toolbar;
}

- (void) setUpTitle
{
    variableTitle = [[UILabel alloc] init];
    variableTitle.font = [UIFont systemFontOfSize:10];
    variableTitle.text = [NSString stringWithFormat:@"Maximum Score Per Letter"];
    variableTitle.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width/4);
    variableTitle.numberOfLines = 0;
    variableTitle.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:variableTitle];
}

- (NSString*) formattedFloat:(float)input
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setMaximumFractionDigits:2];
    NSNumber *num = [NSNumber numberWithFloat:input];
    return [nf stringFromNumber:num];
}

- (void) debug_colors
{
    self.backgroundColor = [UIColor redColor];
    slider.backgroundColor = [UIColor greenColor];
    textField.backgroundColor = [UIColor blueColor];
    variableTitle.backgroundColor = [UIColor purpleColor];
}

- (IBAction)sliderValueChanged:(id)sender
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setMaximumFractionDigits:2];
    [nf setMinimumFractionDigits:2];
    textField.text = [NSString stringWithFormat:@"%@", [self formattedFloat:[(UISlider*)sender value]]];
}

- (IBAction)textFieldDidEndEditing:(UITextField *)field
{
    float value = [[field text] floatValue];
    if (value > slider.maximumValue) {
        field.text = [NSString stringWithFormat:@"%f", slider.maximumValue];
    }
    else if (value < slider.minimumValue) {
        field.text = [NSString stringWithFormat:@"%f", slider.minimumValue];
    }
    slider.value = field.text.floatValue;
    field.text = [self formattedFloat:slider.value];
    return;
}

- (void) resetView {
    [textField endEditing:YES];
}


@end
