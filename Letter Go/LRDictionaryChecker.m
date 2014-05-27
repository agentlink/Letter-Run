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
- (id)init
{
    if (self = [super init]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _setUpDictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Finished loading dictionary");
                //Finished loading dictionary
            });
        });
    }
    return self;
}

- (void)_setUpDictionary
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

- (BOOL)checkForWordInDictionary:(NSString *)word
{
    //Capitalize the letters to handle Qu condition
    word = [word uppercaseString];
    return [self.dictionary containsObject:[word stringByAppendingString:@"\r"]];
}
@end
