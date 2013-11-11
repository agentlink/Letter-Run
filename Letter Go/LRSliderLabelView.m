//
//  LRSliderLabelView.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/8/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRSliderLabelView.h"
#import "LRConstants.h"
#import "LRDifficultyConstants.h"

@interface LRSliderLabelView ()
@property NSDictionary *dataDict;
@end

@implementation LRSliderLabelView
@synthesize slider, textField, variableTitle, dataDict;

- (id) initWithFrame:(CGRect)frame andDictionary:(NSDictionary*)dict{
    if (self = [super initWithFrame:frame andDictionary:dict]) {
        self.dataDict = dict;
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

#pragma mark - Slider Functions

- (void) setUpSlider
{
    slider = [[UISlider alloc] init];
    CGAffineTransform rotate90 = CGAffineTransformMakeRotation(M_PI * -0.5);
    slider.transform = rotate90;
    
    CGFloat slideWidth = self.frame.size.width;
    CGFloat slideHeight = self.frame.size.height * .7;
    CGRect slideFrame = CGRectMake(0, self.frame.size.height - slideHeight, slideWidth, slideHeight);
    slider.frame = slideFrame;
    
    slider.minimumValue = [[dataDict objectForKey:@"min"] floatValue];
    slider.maximumValue = [[dataDict objectForKey:@"max"] floatValue];
    slider.value = [[NSUserDefaults standardUserDefaults] floatForKey:[dataDict objectForKey:USER_DEFAULT_KEY]];
    
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderFinishedMoving:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(sliderFinishedMoving:) forControlEvents:UIControlEventTouchUpOutside];

    [self addSubview:slider];
}

- (void) reloadValue {
    float value =[[NSUserDefaults standardUserDefaults] floatForKey:[dataDict objectForKey:USER_DEFAULT_KEY]];
    [self setSliderText:value];
    [slider setValue:value animated:NO];
}

- (IBAction)sliderValueChanged:(id)sender
{
    [self setSliderText:[(UISlider*)sender value]];
}

- (void) setSliderText:(float)value
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setMaximumFractionDigits:2];
    [nf setMinimumFractionDigits:2];
    textField.text = [NSString stringWithFormat:@"%@", [self formattedFloat:value]];

}

- (IBAction)sliderFinishedMoving:(id)sender
{
    NSString *notificationName = [dataDict objectForKey:USER_DEFAULT_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:slider.value] forKey:notificationName]];
    
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
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resetText)];
    // Add buttons to the toolbar
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, barButtonItem, nil]];
    // Set the toolbar as accessory view of an UITextField object
    textField.inputAccessoryView = toolbar;
}

- (void) setUpTitle
{
    variableTitle = [[UILabel alloc] init];
    variableTitle.font = [UIFont systemFontOfSize:10];
    variableTitle.text = [dataDict objectForKey:@"title"];
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

- (IBAction)textFieldDidEndEditing:(UITextField *)field
{
    float value = [[field text] floatValue];
    if (value > slider.maximumValue) {
        field.text = [NSString stringWithFormat:@"%f", slider.maximumValue];
    }
    else if (value < slider.minimumValue) {
        field.text = [NSString stringWithFormat:@"%f", slider.minimumValue];
    }
    //Only change the slider value if the text field is not empty
    if ([[field text] length])
        slider.value = field.text.floatValue;
    field.text = [self formattedFloat:slider.value];
    return;
}

- (void) resetText {
    [textField endEditing:YES];
}


@end
