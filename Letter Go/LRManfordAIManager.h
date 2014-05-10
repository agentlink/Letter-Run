//
//  LRManfordAIManager.h
//  Letter Go
//
//  Created by Gabe Nicholas on 5/10/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

///The delegate that communicates between the moving envelope and the selected
@protocol LRManfordAIManagerSelectionDelegate <NSObject>
- (void)envelopeSelectedChanged:(BOOL)selected withID:(NSUInteger)uniqueID;
- (void)envelopeCollectedWithID:(NSUInteger)uniqueID;
@end

@interface LRManfordAIManager : SKNode <LRManfordAIManagerSelectionDelegate>

///The shared Manford AI Manager
+ (LRManfordAIManager *)shared;
/*!
 @description Called by the moving envelope to get the its envelope ID
 @param row The row the envelope will be generated in
 @return The value of the next envelopeID
 */
- (NSUInteger)nextEnvelopeIDForRow:(NSUInteger)row;
///@return Returns the row with a selected envelope closest to the mailman
- (NSUInteger)rowWithNextSelectedSlot;
///@description Called when the game is over. It empties the selected envelopes data structure
- (void)resetEnvelopeIDs;
@end
