//
//  LRLetterBlockControlDelegate.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/18/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRMovingEnvelope.h"

@protocol LRLetterBlockControlDelegate <NSObject>

- (void)addEnvelopeToLetterSection:(id)envelope;
- (void)removeEnvelopeFromLetterSection:(id)envelope;

- (void)rearrangementHasBegunWithLetterBlock:(id)letterBlock;
- (void)rearrangementHasFinishedWithLetterBlock:(id)letterBlock;
- (void)deletabilityHasChangedTo:(BOOL)deletable forLetterBlock:(id)letterBlock;

@end
