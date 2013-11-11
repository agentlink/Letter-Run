//
//  LRIncreaseStyleSelector.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/10/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRIncreaseStyleSelector.h"
#import "LRDifficultyConstants.h"
#import "LRDifficultyManager.h"

@interface LRIncreaseStyleSelector ()
@property NSDictionary *dataDict;
@property NSArray *segmentTitles;
@end

@implementation LRIncreaseStyleSelector
@synthesize variableTitle, segControl;

- (id)initWithFrame:(CGRect)frame andDictionary:(NSDictionary*)dict
{

    self = [super initWithFrame:frame andDictionary:dict];
    if (self) {
        self.segmentTitles = @[@"None", @"Linear", @"Exp"];
        self.dataDict = dict;
        [self setUpLabel];
        [self setUpSegments];

    }
    return self;
}

- (void) setUpSegments
{
    segControl = [[UISegmentedControl alloc] initWithItems:self.segmentTitles];
    segControl.frame = CGRectMake(0, variableTitle.frame.size.height, self.frame.size.width, self.frame.size.height - variableTitle.frame.size.height);
    [self reloadValue];
    [segControl addTarget:self action:@selector(updatedValue) forControlEvents:UIControlEventValueChanged];
    [self addSubview:segControl];
}

- (void) setUpLabel
{
    variableTitle = [[UILabel alloc] init];
    variableTitle.font = [UIFont systemFontOfSize:10];
    variableTitle.text = [self.dataDict objectForKey:@"title"];
    variableTitle.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * .66);
    variableTitle.numberOfLines = 0;
    variableTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:variableTitle];
}

- (int) indexOfSegmentFromTitle:(NSString*)title {
    return [self.segmentTitles indexOfObject:title];
}

- (void) reloadValue {
    IncreaseStyle style = [[NSUserDefaults standardUserDefaults] integerForKey:[self.dataDict objectForKey:USER_DEFAULT_KEY]];
    [segControl setSelectedSegmentIndex:style];
}

- (void) updatedValue {
    NSString *notificationName = [self.dataDict objectForKey:USER_DEFAULT_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:segControl.selectedSegmentIndex] forKey:notificationName]];
}

@end
