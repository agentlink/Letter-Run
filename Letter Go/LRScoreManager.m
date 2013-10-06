//
//  LRScoreManager.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/6/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRScoreManager.h"
#import "LRNameConstants.h"

@interface LRScoreManager ()
@property NSMutableArray *submittedWords;
@end

@implementation LRScoreManager

static LRScoreManager *_shared = nil;

+ (LRScoreManager*) shared
{
    //This @synchronized line is for multithreading
    @synchronized (self)
    {
		if (!_shared)
        {
            
			_shared = [[LRScoreManager alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init])
    {
        self.submittedWords = [NSMutableArray array];
    }
    return self;
}

- (void) submitWord:(NSString*)word
{
    [self.submittedWords addObject:word];
}
@end
