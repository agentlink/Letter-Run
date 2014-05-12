//
//  LRSubmitButton.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGameStateDelegate.h"
#import "LRButton.h"


static NSString *const kNotificationSubmitWord = @"Submit a word";

@interface LRSubmitButton : LRButton <LRGameStateDelegate>

@end
