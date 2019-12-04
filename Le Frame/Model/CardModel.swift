//
//  CardModel.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import Foundation

class CardModel {
    
    func getCards() -> [Card]{
        var cards = [Card]()
        
        let allSuits = CardSuit.allCases
        let allRanks = CardRank.allCases
        
        
        for suit in allSuits {
            for rank in allRanks {
                let card = Card()
                card.createImageName(suit: suit, rank: rank)
                cards.append(card)
            }
        }
        return cards
    }
    
    func getRoyalTestDeck() -> [Card] {
        let fullDeck = getCards()
        var newDeck = [Card]()
        let royalRanks = [CardRank.jack, CardRank.queen, CardRank.king]
        
        for card in fullDeck {
            if royalRanks.contains(card.rank!) {
                newDeck.append(card)
            }
        }
        
        return newDeck
    }
    
    func getRegularTestDeck() -> [Card] {
        let fullDeck = getCards()
        var newDeck = [Card]()
        let royalRanks = [CardRank.jack, CardRank.queen, CardRank.king]
        
        for card in fullDeck {
            if !royalRanks.contains(card.rank!) {
                newDeck.append(card)
            }
        }
        
        return newDeck
    }
    
    func getDeckHash(deck: [Card]) -> String {
        var deckHash: String = ""
        for card in deck {
            let rank = String(format: "%02d", card.rank!.getRawValue())
            let suit = card.suit!.getRawValue()
            deckHash += "\(suit)\(rank)"
        }
        
        return deckHash
    }

}

enum CardSuit: String, CaseIterable {
    case heart = "h"
    case diamond = "d"
    case club = "c"
    case spade = "s"
    
    func getRawValue() -> String{
        return self.rawValue
    }
    
}

enum CardRank: Int, CaseIterable {
    case ace = 1, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
    
    func getRawValue() -> Int{
        return self.rawValue
    }
}
