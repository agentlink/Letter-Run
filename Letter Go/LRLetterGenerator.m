//
//  LRLetterGenerator.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/5/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterGenerator.h"

#define PROBABILITY_DICT            @"Scrabble"

@interface LRLetterGenerator ()
@property NSArray *letterProbabilities;
@end

@implementation LRLetterGenerator

static LRLetterGenerator *_shared = nil;

+ (LRLetterGenerator*) shared
{
    //This @synchronized line is for multithreading
    @synchronized (self)
    {
		if (!_shared)
        {
            
			_shared = [[LRLetterGenerator alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init]) {
        [self setUpProbabilityDictionary];
    }
    return self;
}

- (void) setUpProbabilityDictionary
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LetterProbabilities" ofType:@"plist"];
    NSDictionary *probabilityDict = [[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:PROBABILITY_DICT];
    int counter = 0;
    NSMutableArray *letterArray = [NSMutableArray array];
    for (NSString* key in [probabilityDict allKeys])
    {
        NSNumber* numberLocation = [probabilityDict objectForKey:key];
        counter += [numberLocation intValue];
        for (int i = 0; i < counter; i++)
        {
            [letterArray addObject:key];
        }
    }
    self.letterProbabilities = letterArray;
}

- (NSString*)generateLetter
{
    int letterLocation = arc4random()%[self.letterProbabilities count];
    return [self.letterProbabilities objectAtIndex:letterLocation];
}
@end
