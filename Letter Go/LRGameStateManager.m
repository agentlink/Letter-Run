//
//  LRGameStateManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/4/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRGameStateManager.h"
#import "LRGameScene.h"
#import "LRNameConstants.h"

@interface LRGameStateManager ()
@end
@implementation LRGameStateManager

static LRGameStateManager *_shared = nil;

+ (LRGameStateManager*) shared
{
    //This @synchronized line is for multithreading
    @synchronized (self)
    {
		if (!_shared)
        {
            
			_shared = [[LRGameStateManager alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init])
    {

    }
    return self;
}

- (BOOL) isLetterSectionFull
{
    LRLetterSection *letterSection = [[(LRGameScene*)self.scene gamePlayLayer] letterSection];
    return ([letterSection numLettersInSection] == LETTER_CAPACITY);
}

@end
