//
//  LRLevelManager.m
//  Letter Go
//
//  Created by Gabe Nicholas on 6/10/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRLevelManager.h"
#import "LRDifficultyManager.h"
#import "LRProgressManager.h"

@implementation LRLevelManager

- (NSDictionary *)envelopesRequiredToWinCurrentLevel
{
    NSMutableDictionary *reqEnvelopes = [NSMutableDictionary new];
    NSSet *availablePaperColors = [[LRDifficultyManager shared] availablePaperColors];

    //TODO: update how this is calculated
    NSUInteger maxEnvelopes = [[LRProgressManager shared] level] * 2 + 1;
    
    for (NSNumber *num in availablePaperColors)
    {
        LRPaperColor paperColor = [num integerValue];
        NSUInteger increaseLevelVal = maxEnvelopes/(paperColor + 1);
        reqEnvelopes[num] = @(increaseLevelVal);
    }
    
    return reqEnvelopes;
}


@end
