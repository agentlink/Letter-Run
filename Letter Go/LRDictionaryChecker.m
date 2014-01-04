//
//  LRDictionaryChecker.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 10/7/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRDictionaryChecker.h"

#define DICTIONARY_FILE_NAME        @"organizedDict"

@interface LRDictionaryChecker ()
@property NSSet *dictionary;
@end

@implementation LRDictionaryChecker

static LRDictionaryChecker *_shared = nil;

+ (LRDictionaryChecker*) shared
{
    //This @synchronized line is for multithreading
    @synchronized (self)
    {
		if (!_shared)
        {
            
			_shared = [[LRDictionaryChecker alloc] init];
		}
	}
	return _shared;
}

- (id) init
{
    if (self = [super init]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setUpDictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Finished loading dictionary
            });
        });
    }
    return self;
}

- (void) setUpDictionary
{
    NSString* path = [[NSBundle mainBundle] pathForResource:DICTIONARY_FILE_NAME
                                                     ofType:@"txt"];
    NSStringEncoding encoding;
    NSError *error;
    NSString *fileContents = [[NSString alloc] initWithContentsOfFile:path
                                                          usedEncoding:&encoding
                                                                error:&error];
    
    self.dictionary = [NSSet setWithArray:[fileContents componentsSeparatedByString:@"\n"]];
}

- (BOOL)checkForWordInDictionary:(NSString*)word
{
    //Capitalize the letters to handle Qu condition
    word = [word uppercaseString];
    return [self.dictionary containsObject:[word stringByAppendingString:@"\r"]];
}
@end
