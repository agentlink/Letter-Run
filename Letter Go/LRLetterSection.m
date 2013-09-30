//
//  LRLetterSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSection.h"
#import "LRLetterSlot.h"

@interface LRLetterSection ()
@property SKSpriteNode *letterSection;
@property NSMutableArray *letterSlots;

@end

@implementation LRLetterSection

- (void) createSectionContent
{
    //The color will be replaced by a health bar sprite
    self.letterSection = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:self.size];
    [self addChild:self.letterSection];
    self.letterSlots = [[NSMutableArray alloc] init];
    
    //Create the letter slots
    LRLetterSlot *tempSlot = [[LRLetterSlot alloc] init];
    int numLetterSlots = 7;
    float slotMargin = tempSlot.size.width/4;
    float letterSlotWidth = tempSlot.size.width;
    float edgeBuffer = tempSlot.size.width/5;
    for (int i = 0; i < numLetterSlots; i++)
    {
        LRLetterSlot *slot = [[LRLetterSlot alloc] init];
        slot.position = CGPointMake(0 - self.size.width/2 + edgeBuffer + slot.size.width/2 + i * (letterSlotWidth + slotMargin), 0);
        [self.letterSlots addObject:slot];
        [self addChild:slot];
    }
}

@end
