//
//  LRIncreaseStyleSelector.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/10/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDevPauseSubView.h"

@interface LRIncreaseStyleSelector : LRDevPauseSubView {
    UISegmentedControl *segControl;
    UILabel *variableTitle;
}

@property (nonatomic, retain) UISegmentedControl *segControl;
@property (nonatomic, retain) UILabel *variableTitle;


@end
