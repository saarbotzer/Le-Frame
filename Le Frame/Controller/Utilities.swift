//
//  Utilities.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

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

public enum HintType {
    case tappedTooManyTimes
    case waitedTooLong
    case tappedHintButton
}

public let spotImageName = "card-spot.png"

/// The time that takes for a card to move from the new card spot to it's designated spot.
public let cardAnimationDuration : Double = 0.3
 

struct Utilities {
    static func getCenterSpots() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for i in 1...2 {
            for j in 1...2 {
                indexPaths.append(IndexPath(row: i, section: j))
            }
        }
        return indexPaths
    }
    
    static func getSpots(forRank rank: CardRank) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        var spotsList = [(Int, Int)]()
        switch rank {
        case .jack:
            spotsList = [(0, 1), (0, 2), (3, 1), (3, 2)]
        case .queen:
            spotsList = [(1, 0), (2, 0), (1, 3), (2, 3)]
        case .king:
            spotsList = [(0, 0), (0, 3), (3, 0), (3, 3)]
        default:
            spotsList = [(1, 1), (1, 2), (2, 1), (2, 2)]
        }
        
        indexPaths = spotsList.map({ (indexes) -> IndexPath in
            return IndexPath(row: indexes.0, section: indexes.1)
        })
        return indexPaths
        
    }
}


//public let centerSpotsIndexes : [IndexPath] = [IndexPath]
