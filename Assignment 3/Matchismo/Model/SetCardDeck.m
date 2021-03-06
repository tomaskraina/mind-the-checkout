//
//  SetCardDeck.m
//  Matchismo
//
//  Created by Tom on 05.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "SetCardDeck.h"
#import "SetCard.h"

@implementation SetCardDeck

- (id)init
{
    self = [super init];
    
    if (self) {
        for (NSNumber *symbol in [SetCard validSymbols]) {
            for (NSNumber *shading in [SetCard validShadings]) {
                for (NSNumber *color in [SetCard validColors]) {
                    for (NSUInteger number = 1; number <= [SetCard maxNumber]; number++) {
                        SetCard *card = [[SetCard alloc] init];
                        card.number = number;
                        card.symbol = [symbol integerValue];
                        card.shading = [shading integerValue];
                        card.color = [color integerValue];
                        [self addCard:card atTop:YES];
                    }
                }
            }
        }
    }
    
    return self;
}


@end
