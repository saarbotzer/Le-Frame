//
//  ViewController.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var spotsCollectionView: UICollectionView!
    
    @IBOutlet weak var nextCardImageView: UIImageView!
    
    
    var kingsAvailable : Bool = true
    var queensAvailable : Bool = true
    var jacksAvailable : Bool = true
    var spotsAvailable : Bool = true
    
    
    // Get the deck
    var model = CardModel()
    var deck = [Card]()
    
    var nextCard = Card()
    var selectedCardIndexPath: IndexPath?
    
    var gameMode = GameMode.placing
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gameMode = .placing
        
        // Get deck
        deck = model.getCards()
        
        spotsCollectionView.delegate = self
        spotsCollectionView.dataSource = self
        
        // Handle first card
        getNextCard()
        updateNextCardImage()
    }

    
    // MARK: - CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Grid always contains 16 cards (4x4)
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        cell.initializeSpot(with: nil, at: indexPath)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        playTurn(with: indexPath)
        if isGameOver() {
            gameMode = .gameOver
            
            // What to do when game over
            print(gameMode)
        }
    }
    
    func playTurn(with indexPath: IndexPath) {
        let cell = spotsCollectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
            
            
            if gameMode == .placing {
                // What to do when a spot is selected
                if canPutCard(nextCard, at: indexPath) {
                    
                    // Put the card in the spot and go to the next card
                    cell.setCard(nextCard)
                    getNextCard()
                    
                }
                finishedPlacingCard()
            } else if gameMode == .removing {

                // TODO: Mark cards for removal
                
                // In case of pressing an empty spot in removal mode
                if cell.isEmpty {
                    return
                }
                
                let currentCard = cell.card!
                if currentCard.rank! == .ten {
                    cell.removeCard()
                    return
                }

                if selectedCardIndexPath == nil {
                    selectedCardIndexPath = indexPath
                } else {
                    let selectedCardCell = spotsCollectionView.cellForItem(at: selectedCardIndexPath!) as! CardCollectionViewCell
                    let selectedCard = selectedCardCell.card!
        
                    if selectedCard.rank!.getRawValue() + currentCard.rank!.getRawValue() == 10 && selectedCardIndexPath != indexPath {
                        selectedCardCell.removeCard()
                        cell.removeCard()
                        selectedCardIndexPath = nil
                    } else {
                        selectedCardIndexPath = indexPath
                    }
                }
                if !checkForPairs() {
                    
                    // TODO: Ask if finished removing cards?
                    gameMode = .placing
                }
            }
    }
    
    
    func finishedPlacingCard() {
        checkAvailability()
        
        // TODO: Add winning game option
        
        if isGameOver() {
            gameMode = .gameOver
        } else {
            if isBoardFull() {
                gameMode = .removing
            } else {
                gameMode = .placing
            }
        }
        
    }
    
    // MARK: - Card-spot validation methods
    func canPutCard(_ card: Card, at indexPath: IndexPath) -> Bool {
        // If the spot is empty then check whether the spot position and the card rank fit
        
        let cell = spotsCollectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        if cell.isEmpty {
            
            let cardRank = card.rank!
            
            let cardPosition = getCardPosition(indexPath)
            let allowedRanks = getAllowedRanksByPosition(cardPosition: cardPosition)
            
            switch cardRank {
            case .jack:
                return allowedRanks == .jacks
            case .queen:
                return allowedRanks == .queens
            case.king:
                return allowedRanks == .kings
            default:
                // If the card is not royal - true
                return true
            }
        }
        return false
    }
    
    func getAllowedRanksByPosition(cardPosition: (Int, Int)) -> AllowedRanks {
        let row = cardPosition.0
        let column = cardPosition.1
        
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
    
    
    // MARK: - Helper methods
    

    
    func getNextCard() {
        nextCard = deck.remove(at: 0)
        updateNextCardImage()
    }
    
    func updateNextCardImage() {
        nextCardImageView.image = UIImage(named: "\(nextCard.imageName).jpg")
    }
    
    func getCardPosition(_ indexPath: IndexPath) -> (Int, Int) {
        // Gets the card position (row and column) by the indexPath
        
        var row : Int
        var column : Int
        
        let indexPathRow = indexPath.row
        
        if 0...3 ~= indexPathRow {
            row = 0
        }
        
        // Determine row in grid
        switch indexPathRow {
            case 0...3:
                row = 0
            case 4...7:
                row = 1
            case 8...11:
                row = 2
            case 12...15:
                row = 3
            default:
                row = -1
        }

        // Determine column in grid
        switch indexPathRow {
        case let x where x % 4 == 0:
            column = 0
        case let x where (x-1) % 4 == 0:
            column = 1
        case let x where (x-2) % 4 == 0:
            column = 2
        case let x where (x-3) % 4 == 0:
            column = 3
        default:
            column = -1
        }
    
        return (row, column)
    }
    

}


// MARK: - Board actions and variables
extension ViewController {
    
    func isGameWon() -> Bool {
        
        // TODO: Implement isGameWon function
        return false
    }
    
    func isGameOver() -> Bool {
        
        let boardFull = isBoardFull()
        let pairsToRemove = checkForPairs()
        let nextCardRank = nextCard.rank!
        
        if boardFull && !pairsToRemove {
            return true
        }
        if !boardFull && nextCardRank == .jack && !jacksAvailable {
            return true
        }
        if !boardFull && nextCardRank == .queen && !queensAvailable {
            return true
        }
        if !boardFull && nextCardRank == .king && !kingsAvailable {
            return true
        }
        
        return false
    }
    
    func checkForPairs() -> Bool {
        var allNonRoyalValues : [Int] = [Int]()
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            if let cardRankValue = cell.card?.rank!.getRawValue() {
                if cardRankValue < 11 {
                    allNonRoyalValues.append(cardRankValue)
                }
            }
        }
        if allNonRoyalValues.contains(10) {
            return true
        }
        for i in 0..<allNonRoyalValues.count {
            for j in i+1..<allNonRoyalValues.count {
                if allNonRoyalValues[i] + allNonRoyalValues[j] == 10 {
                    return true
                }
            }
        }
        return false
    }
    
    func isBoardFull() -> Bool {
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            if cell.isEmpty {
                return false
            }
        }
        return true
    }

    func checkAvailability() {
        kingsAvailable = false
        queensAvailable = false
        jacksAvailable = false
        spotsAvailable = false
        
        for spot in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            let indexPath = spot.indexPath!
            let allowedRanks = getAllowedRanksByPosition(cardPosition: getCardPosition(indexPath))
            if spot.isEmpty {
                switch allowedRanks {
                case .jacks:
                    jacksAvailable = true
                case .queens:
                    queensAvailable = true
                case .kings:
                    kingsAvailable = true
                default:
                    spotsAvailable = true
                }
            }
            spotsAvailable = spotsAvailable || jacksAvailable || queensAvailable || kingsAvailable
        }
    }
}

