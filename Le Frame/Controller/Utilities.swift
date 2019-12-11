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

enum LoseReason: String {
    case noEmptyJackSpots = "noEmptyJackSpots"
    case noEmptyQueenSpots = "noEmptyQueenSpots"
    case noEmptyKingSpots = "noEmptyKingSpots"
    case noCardsToRemove = "noCardsToRemove"
    case unknown = "unknown"
    
    func getRawValue() -> String {
        return self.rawValue
    }
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

enum HapticFeedbackType {
    case removeError
    case removeSuccess
    case placeError
    case placeSuccess
    case gameOver
    case win
}

public let spotImageName = "card-spot.png"

/// The time that takes for a card to move from the new card spot to it's designated spot.
public let cardAnimationDuration : Double = 0.3
 

public var secondsPassed : Int = 0
public var gameSumMode : SumMode = .ten
public var gameFinished : Bool = false

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
    
    static func getAllowedRanksByPosition(indexPath: IndexPath) -> DesignatedRanks {
        let row = indexPath.row
        let column = indexPath.section
        
        switch (row, column) {
        // Corners
        case (0, 0), (0, 3), (3, 0), (3, 3):
            return .kings
        // Sides
        case (1, 0), (2, 0), (1, 3), (2, 3):
            return .queens
        // Floor and ceiling
        case (0, 1), (0, 2), (3, 1), (3, 2):
            return .jacks
        // Center
        default:
            return .notRoyal
        }
    }
    
    static func showAlert(payload: AlertPayload, parentViewController: UIViewController) {
        var customAlertController: RestartAlertController!;
        if (payload.buttons.count == 2) {
            customAlertController = instantiateViewController(storyboardName: "Main", viewControllerIdentifier: "RestartAlert") as! RestartAlertController;
        }
        else {
            // Action not supported
            return;
        }
        customAlertController?.payload = payload
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertController.setValue(customAlertController, forKey: "contentViewController")
        
        var heightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: parentViewController.view.frame.height * 0.30)

        alertController.view.addConstraint(heightConstraint)
        parentViewController.present(alertController, animated: true, completion: nil)
    }
    
    static func instantiateViewController(storyboardName: String, viewControllerIdentifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main);
        return storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier);
    }
    
    static func formatSeconds(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        
        var timeString = ""
        
        if hours > 0 {
            timeString = String(format: "%02i:%02i:%02i hrs", hours, minutes, seconds)
        } else if minutes > 0 {
            timeString = String(format: "%02i:%02i mins", minutes, seconds)
        } else {
            timeString = String(format: "%02i secs", seconds)
        }
        
        return timeString
    }
}


//public let centerSpotsIndexes : [IndexPath] = [IndexPath]
