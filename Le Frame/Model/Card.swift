//
//  Card.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import Foundation

class Card: CustomStringConvertible {
    
    var imageName = ""
    var rank: CardRank?
    var suit: CardSuit?
    
    init(suit: CardSuit, rank: CardRank) {
        self.imageName = "\(suit.getRawValue())\(rank.getRawValue()).jpg"
        self.rank = rank
        self.suit = suit
    }
    
    init() {
        self.imageName = spotImageName
    }
    
    var description: String {
        return imageName
    }
    
    func createCard(withSuit suit: CardSuit, withRank rank: CardRank) {
        self.imageName = "\(suit.getRawValue())\(rank.getRawValue()).jpg"
        self.rank = rank
        self.suit = suit
    }
    
}
