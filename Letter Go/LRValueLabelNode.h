//
//  LRValueLabelNode.h
//  Letter Go
//
//  Created by Gabe Nicholas on 6/4/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LRValueLabelNode : SKLabelNode

- (id)initWithFontNamed:(NSString *)fontName initialValue:(NSInteger)value;

/*!
 Update the value over a total amount of time
 @param totalDuration: how long it should take to update the value node to updatedValue
*/
- (void)updateValue:(NSInteger)updatedValue animated:(BOOL)animated totalDuration:(CGFloat)totalDuration;
/*!
 Update the value taking a certain amount of time per value in between
 @param duration: how long it should take to chagne the value node by 1
 */
- (void)updateValue:(NSInteger)updatedValue animated:(BOOL)animated durationPerNumber:(CGFloat)duration;

@property (nonatomic, readonly) NSInteger value;
@property (nonatomic, strong) NSString *preValueString;
@property (nonatomic, strong) NSString *postValueString;
@end
