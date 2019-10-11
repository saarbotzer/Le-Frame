//
//  ViewController.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var spotsCollectionView: UICollectionView!
    
    @IBOutlet weak var nextCardImageView: UIImageView!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var doneRemovingBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    
    var kingsAvailable : Bool = true
    var queensAvailable : Bool = true
    var jacksAvailable : Bool = true
    var spotsAvailable : Bool = true
    
    
    var model = CardModel()
    var deck = [Card]()
    
    var nextCard = Card()
    var firstSelectedCardIndexPath: IndexPath?
    var secondSelectedCardIndexPath: IndexPath?
    
    var gameMode = GameMode.placing
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spotsCollectionView.delegate = self
        spotsCollectionView.dataSource = self
        
        initializeGame()
        
    }
    
    // IBActions
    @IBAction func removePressed(_ sender: Any) {
        // Validity checks (no index paths, same index path)
        // TODO: maybe change ifs to if lets
        
        // Option 1 - Only one card is selected
        if firstSelectedCardIndexPath != nil && secondSelectedCardIndexPath == nil {
            let firstCardCell = spotsCollectionView.cellForItem(at: firstSelectedCardIndexPath!) as! CardCollectionViewCell
            let firstCard = firstCardCell.card!
            // If the card is 10 - remove
            if firstCard.rank! == .ten {
                firstCardCell.removeCard()
            }
        // Option 2 - Two cards are selected
        } else if firstSelectedCardIndexPath != nil && secondSelectedCardIndexPath != nil {
            let firstCardCell = spotsCollectionView.cellForItem(at: firstSelectedCardIndexPath!) as! CardCollectionViewCell
            let firstCard = firstCardCell.card!
            
            let secondCardCell = spotsCollectionView.cellForItem(at: secondSelectedCardIndexPath!) as! CardCollectionViewCell
            let secondCard = secondCardCell.card!
            
            // If the cards match - remove
            if firstCard.rank!.getRawValue() + secondCard.rank!.getRawValue() == 10 {
                firstCardCell.removeCard()
                secondCardCell.removeCard()
            }
        }
        resetCardIndexes()
        markAllCardAsNotSelected()
    }
    
    
    
    // IBActions
    @IBAction func doneRemovingPressed(_ sender: Any) {
        setGameMode(mode: .placing)
        markAllCardAsNotSelected()
    }
}

// MARK: - CollectionView Methods

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Grid always contains 16 cards (4x4)
        return 4
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        cell.initializeSpot(with: nil, at: indexPath)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        playTurn(with: indexPath)
        if isGameOver() {
            setGameMode(mode: .gameOver)
            
            // What to do when game over
            
            showAlert("Game Over", "You've lost")
            print(gameMode)
        }
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
//        let alertAction  = UIAlertAction(title: "Restart", style: .default, handler: nil)
        let alertAction = UIAlertAction(title: "Restart", style: .default) { (action) in
            self.initializeGame()
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = collectionView.frame.height / 4 - 10
        let width = height / 3 * 2
        
        return CGSize(width: width, height: height)
    }
}


// MARK: Spots Handling and Interface Methods
extension ViewController {
    
    // Update Interface
    func setGameMode(mode: GameMode) {
        
        gameMode = mode
        var labelText = ""
        switch mode {
        case .placing:
            updateNextCardImage()
            doneRemovingBtn.isHidden = true
            removeBtn.isHidden = true
            labelText = "Mode: Card Placing"
        case .removing:
            nextCardImageView.image = UIImage(named: "green_card.png")
            doneRemovingBtn.isHidden = false
            removeBtn.isHidden = false
            labelText = "Mode: Card Removing"
        case .gameOver:
            labelText = "Game Over"
        case .won:
            labelText = "You've Won!"
        }
        modeLabel.text = labelText
    }
    
    
    // Spots Handling
    func resetCardIndexes() {
        firstSelectedCardIndexPath = nil
        secondSelectedCardIndexPath = nil
    }
    
    
    // Board Handling
    func finishedPlacingCard() {
        checkAvailability()
        
        // TODO: Add winning game option
        
        if isGameOver() {
            setGameMode(mode: .gameOver)
        } else {
            if isBoardFull() {
                setGameMode(mode: .removing)
            } else {
                setGameMode(mode: .placing)
            }
        }
        
    }
    
    // Spots Handling
    func removeAllCards() {
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            cell.removeCard()
        }
    }
    
    // Spots Handling
    func markAllCardAsNotSelected() {
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            cell.setNotSelected()
        }
    }
    
    // Spots Handling
    func markCardAsSelected(at indexPath: IndexPath) {
        if let cell = spotsCollectionView.cellForItem(at: indexPath) as? CardCollectionViewCell {
            cell.setSelected()
        }
    }
}

// MARK: - Game Logic Functions
extension ViewController {
    
    // Game Logic
    func initializeGame() {
        setGameMode(mode: .placing)
        
        markAllCardAsNotSelected()
        removeAllCards()
        
        // Get deck
        deck = model.getCards()
        deck.shuffle()
        
        // Handle first card
        getNextCard()
        updateNextCardImage()
    }
    
    // Game Logic
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
                
                if firstSelectedCardIndexPath == nil {
                    firstSelectedCardIndexPath = indexPath
                    secondSelectedCardIndexPath = nil
                    markCardAsSelected(at: firstSelectedCardIndexPath!)
                } else {
                    if firstSelectedCardIndexPath == indexPath{
                        firstSelectedCardIndexPath = nil
                        secondSelectedCardIndexPath = nil
                        markAllCardAsNotSelected()
                    } else if secondSelectedCardIndexPath != nil {
                        markAllCardAsNotSelected()
                        firstSelectedCardIndexPath = indexPath
                        secondSelectedCardIndexPath = nil
                        markCardAsSelected(at: firstSelectedCardIndexPath!)
                    } else {
                        secondSelectedCardIndexPath = indexPath
                        markCardAsSelected(at: secondSelectedCardIndexPath!)
                    }
                }
                
            }
    }
    
    // Game Logic
    func canPutCard(_ card: Card, at indexPath: IndexPath) -> Bool {
        // If the spot is empty then check whether the spot position and the card rank fit
        
        let cell = spotsCollectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        if cell.isEmpty {
            
            let cardRank = card.rank!
            
            let allowedRanks = getAllowedRanksByPosition(indexPath: indexPath)
            
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
    
    // Game Logic
    func isGameWon() -> Bool {
        
        // TODO: Implement isGameWon function
        return false
    }
    
    // Game Logic
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
    
    // Game Logic
    func getAllowedRanksByPosition(indexPath: IndexPath) -> AllowedRanks {
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
    
    // Game Logic
    func getNextCard() {
        nextCard = deck.remove(at: 0)
        updateNextCardImage()
    }
    
    // Game Logic?
    func updateNextCardImage() {
        nextCardImageView.image = UIImage(named: "\(nextCard.imageName).jpg")
    }
    
    // Game Logic
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
    
    // Game Logic
    func isBoardFull() -> Bool {
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            if cell.isEmpty {
                return false
            }
        }
        return true
    }

    // Game Logic
    func checkAvailability() {
        kingsAvailable = false
        queensAvailable = false
        jacksAvailable = false
        spotsAvailable = false
        
        for spot in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            let indexPath = spot.indexPath!
            let allowedRanks = getAllowedRanksByPosition(indexPath: indexPath)
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

