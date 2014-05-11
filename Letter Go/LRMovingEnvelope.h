//
//  LRMovingBlock.h
//  Letter Go
//
//  Created by Gabriel Nicholas on 1/15/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRLetterBlock.h"

@protocol LRMovingBlockTouchDelegate;
@interface LRMovingEnvelope : LRLetterBlock

@property (nonatomic, weak) id<LRMovingBlockTouchDelegate> touchDelegate;
///The row in which the letter block appears on screen
@property (nonatomic) NSUInteger row;
///The player has selected the envelope while on the main game screen
@property (nonatomic) BOOL selected;
///If this is YES, show the open letter sprite
@property (nonatomic) BOOL envelopeOpen;
///A unique ID for the envelope that contains information on its slot and order in generation
@property (nonatomic,readonly) NSUInteger envelopeID;

///Creates an instance of LRMovingEnvelope with a specific letter and color of paper
+ (LRMovingEnvelope *)movingBlockWithLetter:(NSString *)letter paperColor:(LRPaperColor)paperColor;
///Returns the file name ofr a given paper color
+ (NSString *)stringFromPaperColor:(LRPaperColor)paperColor open:(BOOL)open;
///Returns the position of an enveope at a given row
+ (CGPoint)envelopePositionForRow:(NSUInteger)row;

///Call this when the envelope is past the point where its colelcted state can be changed
- (void)updateForRemoval;

@end

@protocol LRMovingBlockTouchDelegate <NSObject>
- (void)playerSelectedMovingBlock:(LRMovingEnvelope *)movingBlock;
@end