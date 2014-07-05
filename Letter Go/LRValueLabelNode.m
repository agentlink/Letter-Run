//
//  LRValueLabelNode.m
//  Letter Go
//
//  Created by Gabe Nicholas on 6/4/14.
//  Copyright (c) 2014 Gabe Nicholas. All rights reserved.
//

#import "LRValueLabelNode.h"

@interface LRValueLabelNode()
@property (nonatomic, readwrite) NSInteger value;
@end

@implementation LRValueLabelNode

- (id)initWithFontNamed:(NSString *)fontName initialValue:(NSInteger)value
{
    if (self = [super initWithFontNamed:fontName])
    {
        self.value = value;
    }
    return self;
}

- (void)updateValue:(NSInteger)updatedValue animated:(BOOL)animated totalDuration:(CGFloat)duration
{
    CGFloat valueDiff = (CGFloat)ABS(updatedValue - self.value);
    CGFloat timePerNumber = valueDiff/duration;
    [self updateValue:updatedValue animated:animated durationPerNumber:timePerNumber];
}

- (void)updateValue:(NSInteger)updatedValue animated:(BOOL)animated durationPerNumber:(CGFloat)duration
{
    if (!animated)
    {
        if (duration > 0.0)
        {
            SKAction *wait = [SKAction waitForDuration:duration];
            [self runAction:wait completion:^{
                self.value = updatedValue;
            }];
        }
        else
        {
            self.value = updatedValue;
        }
        return;
    }
    
    NSMutableArray *changeLabelActions = [NSMutableArray new];
    NSInteger iterator = self.value;
    while (iterator != updatedValue) {
        if (updatedValue > iterator)
            iterator++;
        else
            iterator--;
        SKAction *pauseTime = [SKAction waitForDuration:duration];
        SKAction *update = [SKAction runBlock:^{
            self.value = iterator;
        }];
        [changeLabelActions addObjectsFromArray:@[pauseTime, update]];
    }
    SKAction *changeAction = [SKAction sequence:changeLabelActions];
    [self runAction:changeAction];
    

}

- (void)setValue:(NSInteger)value
{
    _value = value;
    NSMutableString *text = [NSMutableString stringWithFormat:@"%li", (long)value];
    if (self.preValueString) [text insertString:self.preValueString atIndex:0];
    if (self.postValueString) [text appendString:self.postValueString];
    self.text = text;
}

- (void)setPreValueString:(NSString *)preValueString
{
    BOOL newVal = ![_preValueString isEqualToString:preValueString];
    _preValueString = preValueString;
    if (newVal)
        self.value = self.value;
}

- (void)setPostValueString:(NSString *)postValueString
{
    BOOL newVal = ![_postValueString isEqualToString:postValueString];
    _postValueString = postValueString;
    if (newVal)
        self.value = self.value;
}
@end


