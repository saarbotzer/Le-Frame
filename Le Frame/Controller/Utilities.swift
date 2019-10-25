//
//  Utilities.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import Foundation

enum GameMode {
    case placing
    case removing
    case gameOver
    case won
}

public let spotImageName = "green_card.png"

/// The times that takes for a card to move from the new card spot to it's designated spot.
public let cardAnimationDuration : Double = 0.3
