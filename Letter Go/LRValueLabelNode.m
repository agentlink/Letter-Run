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

- (void)updateValue:(NSInteger)updatedValue animated:(BOOL)animated
{
    NSMutableArray *changeLabelActions = [NSMutableArray new];
    NSInteger iterator = self.value;
    while (iterator != updatedValue) {
        iterator ++;
        SKAction *pauseTime = [SKAction waitForDuration:.01];
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
    self.text = [NSString stringWithFormat:@"%li", (long)value];
}

@end


