//
//  LRLetterAdditionDeletionDelegate.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/18/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LRLetterAdditionDeletionDelegate <NSObject>

- (void) addEnvelopeToLetterSection:(id)envelope;
- (void) removeEnvelopeFromLetterSection:(id)envelope;

@end
