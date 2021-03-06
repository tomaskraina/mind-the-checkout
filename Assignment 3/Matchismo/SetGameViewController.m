//
//  SetGameViewController.m
//  Matchismo
//
//  Created by Tom on 05.03.13.
//  Copyright (c) 2013 Tom Kraina (Advanced iOS Application Development DTU Course). All rights reserved.
//

#import "SetGameViewController.h"
#import "SetCardDeck.h"
#import "SetCard.h"
#import "SetCardCollectionViewCell.h"

const CGFloat SetCardTransformationDuration = .1;
const NSUInteger SetCardStartingCount = 12;
NSString * const SetCardGameTypeName = @"Set Game";
const CGFloat SetCardSizeChange = 10;

@interface SetGameViewController ()

@end

@implementation SetGameViewController

#pragma mark - Properties

- (CardMatchingGameMode)gameMode
{
    return CardMatchingGameModeMatch3Cards;
}

- (Deck *)createDeck
{
    return [[SetCardDeck alloc] init];
}

- (NSString *)gameTypeName
{
    return SetCardGameTypeName;
}

- (NSUInteger)startingCardCount
{
    return SetCardStartingCount;
}

#pragma mark - Required overrides

- (NSAttributedString *)attributedStringForCard:(SetCard *)card
{    
    UIColor *fillColor = [[self colorFromSetCard:card] colorWithAlphaComponent:[self alphaFromSetCard:card]];

    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:15.],
                                 NSForegroundColorAttributeName: fillColor,
                                 NSStrokeColorAttributeName: [self colorFromSetCard:card],
                                 NSStrokeWidthAttributeName: @-10
                                 };
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[card contents] attributes:attributes];
    
    return attributedString;
}

- (void)makeViewSmaller:(UIView *)view
{
    CGRect frame = view.frame;
    frame.size.width -= SetCardSizeChange;
    frame.size.height -= SetCardSizeChange;
    frame.origin.x += SetCardSizeChange/2;
    frame.origin.y += SetCardSizeChange/2;
    view.frame = frame;
}

- (void)makeViewBigger:(UIView *)view
{
    CGRect frame = view.frame;
    frame.size.width += SetCardSizeChange;
    frame.size.height += SetCardSizeChange;
    frame.origin.x -= SetCardSizeChange/2;
    frame.origin.y -= SetCardSizeChange/2;
    view.frame = frame;
}

- (void)updateCell:(SetCardCollectionViewCell *)cell usingCard:(SetCard *)card animated:(BOOL)animated
{
    if (![card isKindOfClass:[SetCard class]] || ![cell isKindOfClass:[SetCardCollectionViewCell class]]) {
        return;
    }

    if (animated && cell.setCardView.isSelected != card.isFaceUp) {
        [UIView animateWithDuration:SetCardTransformationDuration animations:^{
            if (card.isFaceUp) {
                [self makeViewBigger:cell.setCardView];
            }
            else {
                [self makeViewSmaller:cell.setCardView];
            }
        }];
    }
    else if (cell.setCardView.isSelected && !card.isFaceUp) {
        [self makeViewSmaller:cell.setCardView];
    }
    else if (!cell.setCardView.isSelected && card.isFaceUp) {
        [self makeViewBigger:cell.setCardView];
    }

    cell.setCardView.selected = card.isFaceUp;
    cell.setCardView.number = card.number;
    cell.setCardView.color = card.color;
    cell.setCardView.shading = card.shading;
    cell.setCardView.symbol = card.symbol;
}

#pragma mark Optional overrides

- (BOOL)removesUnplayableCards
{
    return YES;
}

#pragma mark - Helpers

- (UIColor *)colorFromSetCard:(SetCard *)card
{
    return [SetCardView colorFromColor:card.color];
}

- (float)alphaFromSetCard:(SetCard *)card
{
    switch (card.shading) {
        case SetCardShadingOpen:
            return 0;
        case SetCardShadingStripped:
            return .2;
        default:
            return 1;
    }
}


@end
