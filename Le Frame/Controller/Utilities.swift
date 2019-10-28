//
//  Utilities.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import Foundation

enum GameStatus {
    case placing
    case removing
    case gameOver
    case won
}

public enum SumMode: Int {
    case ten = 10
    case eleven = 11
    
    func getRawValue() -> Int {
        return self.rawValue
    }
}

public let spotImageName = "green_card.png"

/// The time that takes for a card to move from the new card spot to it's designated spot.
public let cardAnimationDuration : Double = 0.3
