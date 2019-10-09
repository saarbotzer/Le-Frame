//
//  Card.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import Foundation

class Card {
    
    var imageName = ""
    var rank: CardRank?
    var suit: CardSuit?
    
    func createImageName(suit: CardSuit, rank: CardRank) {
        self.imageName = "\(suit.getRawValue())\(rank.getRawValue())"
        self.rank = rank
        self.suit = suit
    }
}
