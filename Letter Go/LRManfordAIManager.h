//
//  LRManfordAIManager.h
//  Letter Go
//
//  Created by Gabe Nicholas on 5/10/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

extern NSUInteger const kLRManfordAIManagerEmptyRow;

///The delegate that communicates between the moving envelope and the selected
@protocol LRManfordAIManagerSelectionDelegate <NSObject>
- (void)envelopeSelectedChanged:(BOOL)selected withID:(NSUInteger)uniqueID;
- (void)envelopeCollectedWithID:(NSUInteger)uniqueID;
@end

@protocol LRManfordMovementDelegate <NSObject>
- (void)nextEnvelopeRowChangedToRow:(NSUInteger)row;
@end

@interface LRManfordAIManager : SKNode <LRManfordAIManagerSelectionDelegate>

///The delegate that tells Manford to change position
@property (nonatomic, weak) SKSpriteNode <LRManfordMovementDelegate> *movementDelegate;

///The shared Manford AI Manager
+ (LRManfordAIManager *)shared;
/*!
 @description Called by the moving envelope to get the its envelope ID
 @param row The row the envelope will be generated in
 @return The value of the next envelopeID
 */
- (NSUInteger)nextEnvelopeIDForRow:(NSUInteger)row;
///@description Called when the game is over. It empties the selected envelopes data structure
- (void)resetEnvelopeIDs;
@end
