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
    
    // Get the deck
    var model = CardModel()
    var deck = [Card]()
    
    var nextCard = Card()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        cell.setEmpty()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        
        // What to do when a spot is selected
        if canPutCard(nextCard, at: indexPath) {
            print("\(getCardPosition(indexPath)) - \(nextCard.imageName)")
            
            // Put the card in the spot and go to the next card
            cell.setCard(nextCard)
            getNextCard()
            
        } else {
            // If the spot already has a card
            // TODO: Check if it's card-removal code and if so - check whether to remove cards or not
            cell.setEmpty() // remove line
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
