//
//  CardModel.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import Foundation

class CardModel {
    
    /**
     Creates a regular deck
     
     - Returns: An array of Cards that represents a deck
     */
    func getDeck() -> [Card] {
        var cards = [Card]()
        
        let allSuits = CardSuit.allCases
        let allRanks = CardRank.allCases
        
        
        for suit in allSuits {
            for rank in allRanks {
                let card = Card()
                card.createCard(withSuit: suit, withRank: rank)
                cards.append(card)
            }
        }
        return cards
    }
    
    /**
     Creates a deck from royal cards
     
     - Returns: An array of Cards that represents a deck
     */
    func getRoyalDeck() -> [Card] {
        let fullDeck = getDeck()
        var newDeck = [Card]()
        let royalRanks = [CardRank.jack, CardRank.queen, CardRank.king]
        
        for card in fullDeck {
            if royalRanks.contains(card.rank!) {
                newDeck.append(card)
            }
        }
        
        return newDeck
    }
    
    /**
     Creates a deck from non-royal cards
     
     - Returns: An array of Cards that represents a deck
     */
    func getNonRoyalDeck() -> [Card] {
        let fullDeck = getDeck()
        var newDeck = [Card]()
        let royalRanks = [CardRank.jack, CardRank.queen, CardRank.king]
        
        for card in fullDeck {
            if !royalRanks.contains(card.rank!) {
                newDeck.append(card)
            }
        }
        
        return newDeck
    }
    
    /**
     Creates a deck from a deck string
     
     - Parameter string: The string to create the deck from. Should be of format 'aXX', where a is the suit (h, s, c, d) and XX is the rank (01-13)
     - Parameter fullDeck: Represents whether the string represents a fully sized deck (52 cards) or not
     
     - Returns: An array of Cards that represents a deck
     */
    func getDeck(from deckString: String, fullDeck: Bool) -> [Card] {
        //TODO: Validity checks on the string
        
        var deck = [Card]()
        if deckString.count != 3 * 52 && fullDeck {
            return getDeck()
        } else {
            // TODO: Create the deck from the string
            let stringToSplit = String(deckString.enumerated().map { $0 > 0 && $0 % 3 == 0 ? [":", $1] : [$1]}.joined())
            let cardsStrings = stringToSplit.split(separator: ":")
            for cardSubString in cardsStrings {
                let cardString = String(cardSubString)
                let suit = CardSuit.create(from: cardString[0])
                let rank = CardRank.create(from: Int(cardString[1..<3]) ?? -1)
                if suit != nil && rank != nil {
                    let card = Card()
                    card.createCard(withSuit: suit!, withRank: rank!)
                    deck.append(card)
                }
            }
            return deck
        }
    }
    
    
    /**
     Gets the deck of the wanted type.
     
     - Parameter deckType: The wanted deck type (only royals, only regular without royals, random deck or from deckString)
     - Parameter random: Should the deck be randomized or ordered as built
     - Parameter string: If chosen deck type is .fromString, this is the deck's string
     - Parameter fullDeck: If chosen deck type is .fromString, this represents whether the string represents a fully sized deck (52 cards) or not
     
     - Returns: An array of Cards that represents a deck
     */
    func getDeck(ofType deckType: DeckType, random: Bool, from string: String?, fullDeck: Bool?) -> [Card] {
        
        var deck: [Card] = [Card]()
        
        switch deckType {
        case .onlyRoyals:
            deck = self.getRoyalDeck()
        case .notRoyals:
            deck = self.getNonRoyalDeck()
        case .regularDeck:
            deck = self.getDeck()
        case .fromString:
            if string != nil && fullDeck != nil {
                deck = self.getDeck(from: string!, fullDeck: fullDeck!)
            } else {
                print("Couldn't create deck from string \(string) with fullDeck property \(fullDeck)")
                deck = self.getDeck()
            }
        }
        
        if random {
            deck.shuffle()
        }
        return deck
    }
    
    /**
     Creates a string that represents the deck.
     
     - Parameter deck: The deck to create the string from
     
     - Returns: A string that represents the deck
     */
    func getDeckString(deck: [Card]) -> String {
        var deckHash: String = ""
        for card in deck {
            let rank = String(format: "%02d", card.rank!.getRawValue())
            let suit = card.suit!.getRawValue()
            deckHash += "\(suit)\(rank)"
        }
        
        return deckHash
    }

}


enum DeckType {
    case onlyRoyals, notRoyals, regularDeck, fromString
}

enum CardSuit: String, CaseIterable {
    case heart = "h"
    case diamond = "d"
    case club = "c"
    case spade = "s"
    
    func getRawValue() -> String {
        return self.rawValue
    }
    
    static func create(from rawValue: String) -> CardSuit? {
        switch rawValue {
        case "h":
            return .heart
        case "d":
            return .diamond
        case "c":
            return .club
        case "s":
            return .spade
        default:
            return nil
        }
    }
}

enum CardRank: Int, CaseIterable {
    case ace = 1, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
    
    func getRawValue() -> Int{
        return self.rawValue
    }
    
    static func create(from rawValue: Int) -> CardRank? {
        let cardRanks : [CardRank] = [.ace, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king]
        
        if rawValue > 0 && rawValue < 14 {
            return cardRanks[rawValue - 1]
        } else {
            return nil
        }
        
    }
}



extension String {

  var length: Int {
    return count
  }

  subscript (i: Int) -> String {
    return self[i ..< i + 1]
  }

  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }

  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }

  subscript (r: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                        upper: min(length, max(0, r.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }

}
