//
//  LRLetterSection.m
//  Letter Go
//
//  Created by Gabriel Nicholas on 9/26/13.
//  Copyright (c) 2013 Gabe Nicholas. All rights reserved.
//

#import "LRLetterSection.h"
#import "LRLetterSlot.h"
#import "LRNameConstants.h"
#import "LRLetterBlockGenerator.h"

#define LETTER_CAPACITY             7

@interface LRLetterSection ()
@property SKSpriteNode *letterSection;
@property NSMutableArray *letterSlots;
@end

@implementation LRLetterSection

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLetterToSection:) name:NOTIFICATION_ADDED_LETTER object:nil];
    }
    return self;
}

- (void) createSectionContent
{
    //The color will be replaced by a health bar sprite
    self.letterSection = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:self.size];
    [self addChild:self.letterSection];
    self.letterSlots = [[NSMutableArray alloc] initWithCapacity:LETTER_CAPACITY];
    
    
    //Create the letter slots
    LRLetterSlot *tempSlot = [[LRLetterSlot alloc] init];
    float slotMargin = tempSlot.size.width/4;
    float letterSlotWidth = tempSlot.size.width;
    float edgeBuffer = tempSlot.size.width/5;
    for (int i = 0; i < LETTER_CAPACITY; i++)
    {
        LRLetterSlot *slot = [[LRLetterSlot alloc] init];
        slot.position = CGPointMake(0 - self.size.width/2 + edgeBuffer + slot.size.width/2 + i * (letterSlotWidth + slotMargin), 0);
        [self.letterSlots addObject:slot];
        [self addChild:slot];
    }
}

- (void) addLetterToSection:(NSNotification*)notification
{
    //Get the letter from the notificaiton
    NSString *letter = [[notification userInfo] objectForKey:NOTIFICATION_ADDED_LETTER];
    LRLetterSlot *currentLetterSlot = nil;
    for (LRLetterSlot* slot in self.letterSlots)
    {
        if ([slot isLetterSlotEmpty]) {
            currentLetterSlot = slot;
            break;
        }
    }
    //If all the letter slots are full
    if (!currentLetterSlot) {
        return;
    }
    currentLetterSlot.currentBlock = [LRLetterBlockGenerator createBlockForSlotWithLetter:letter];
}
@end
