//
//  LRMailman.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 11/3/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRObject.h"

typedef NS_ENUM(BOOL, MailmanScreenSide) {
    MailmanScreenLeft = 0,
    MailmanScreenRight
};

@interface LRMailman : LRObject

@property (nonatomic) MailmanScreenSide screenSide;
@property (readonly) CGPoint letterEntryPoint;

- (CGFloat) xPositionForScreenSide:(MailmanScreenSide)screenSide;

@end
