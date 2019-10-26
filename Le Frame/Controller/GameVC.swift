//
//  ViewController.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class GameVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: Properties & Declerations
    // IBOutlets
    @IBOutlet weak var spotsCollectionView: UICollectionView!
    @IBOutlet weak var nextCardImageView: UIImageView!
    @IBOutlet weak var doneRemovingBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    // Spots available by rank
    var kingsAvailable : Bool = true
    var queensAvailable : Bool = true
    var jacksAvailable : Bool = true
    var spotsAvailable : Bool = true
    
    // Game Data
    var model = CardModel()
    var deck = [Card]()

    var nextCard = Card()
    var firstSelectedCardIndexPath: IndexPath?
    var secondSelectedCardIndexPath: IndexPath?
    
    var gameStatus = GameStatus.placing
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        spotsCollectionView.delegate = self
        spotsCollectionView.dataSource = self
        
        initializeGame()
    }
    
    // MARK: - IBActions
    
    /** Called when **Remove** button is pressed.
     The function checks whether one card or two cards are selected, and removes them if they are summed to 10.
    */
    @IBAction func removePressed(_ sender: Any) {
        // Validity checks (no index paths, same index path)
        // TODO: maybe change ifs to if lets
        
        // Option 1 - Only one card is selected
        if firstSelectedCardIndexPath != nil && secondSelectedCardIndexPath == nil {
            let firstCardCell = spotsCollectionView.cellForItem(at: firstSelectedCardIndexPath!) as! CardCollectionViewCell
            let firstCard = firstCardCell.card!
            // If the card is 10 - remove
            if sumMode == .ten && firstCard.rank! == .ten {
                firstCardCell.removeCard()
            }
        // Option 2 - Two cards are selected
        } else if firstSelectedCardIndexPath != nil && secondSelectedCardIndexPath != nil {
            let firstCardCell = spotsCollectionView.cellForItem(at: firstSelectedCardIndexPath!) as! CardCollectionViewCell
            let firstCard = firstCardCell.card!
            
            let secondCardCell = spotsCollectionView.cellForItem(at: secondSelectedCardIndexPath!) as! CardCollectionViewCell
            let secondCard = secondCardCell.card!
            
            // If the cards match - remove
            if firstCard.rank!.getRawValue() + secondCard.rank!.getRawValue() == sumMode.getRawValue() {
                firstCardCell.removeCard()
                secondCardCell.removeCard()
            }
        }
        resetCardIndexes()
        markAllCardAsNotSelected()
    }
    
    /** Called when **Done** button is pressed.
     Switches between removing and placing game modes and deselects all cards.
     */
    @IBAction func doneRemovingPressed(_ sender: Any) {
        if gameStatus == .removing {
            setGameStatus(status: .placing)
        }
        markAllCardAsNotSelected()
    }

    // MARK: - CollectionView Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        
        if gameStatus != .removing {
            if isGameOver() {
                setGameStatus(status: .gameOver)
            } else if isBoardFull() && isGameWon() {
                setGameStatus(status: .won)
            }
        }
    }
    
    


    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = collectionView.frame.height / 4 - 10
        let width = height / 3 * 2
        
        return CGSize(width: width, height: height)
    }
    // MARK: - Spots Handling and Interface Methods

    /**
     Animates a card from the next card spot to the requested spot in the grid
     
     - Parameter card: The card that is being moved.
     - Parameter indexPath: The destination IndexPath in the cards grid
     
     */
    func animateCard(card: Card, to indexPath: IndexPath) {
        
        // Get destination cell
        let cell = spotsCollectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        
        // Create moving imageView
        let tempImageView = UIImageView(image: UIImage(named: "\(card.imageName).jpg"))
        
        // Get origin point and size
        let originPoint = nextCardImageView.superview?.convert(nextCardImageView.frame.origin, to: nil)
        let originSize = nextCardImageView.frame.size
        let originFrame = CGRect(origin: originPoint!, size: originSize)
        
        // Get destination point and size
        let destinationPoint = cell.superview?.convert(cell.frame.origin, to: nil)
        let destinationSize = cell.frame.size
        let destinationFrame = CGRect(origin: destinationPoint!, size: destinationSize)
        
        // Apply origin properties to imageView
        tempImageView.frame = originFrame
        
        // Add the imageView to the main view
        view.addSubview(tempImageView)
 
        // Animate
        UIView.animate(withDuration: cardAnimationDuration) {
            tempImageView.frame = destinationFrame
        }
        
        // Remove imageView after when arriving to destination
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
            tempImageView.removeFromSuperview()
        }

    }
    
    
    /**
     Shows alert for game ends (win/lose) with *OK* and *Restart* actions.
     
     - Parameter title: The title of the alert
     - Parameter message: The message of the alert
     */
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let restartAction = UIAlertAction(title: "Restart", style: .default) { (action) in
            self.initializeGame()
        }
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(restartAction)
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }
    
    /**
     Changes the game status, changes the UI accordingly and calls functions that acts according to the new game status.
     
     - Parameter status: The game status to set
     */
    func setGameStatus(status: GameStatus) {
        
        gameStatus = status
        switch status {
        case .placing:
            updateNextCardImage()
            showRemovalUI(show: false)
        case .removing:
            showRemovalUI(show: true)
        case .gameOver:
            showRemovalUI(show: false)
            gameOver()
        case .won:
            showRemovalUI(show: false)
            gameWon()
        }
    }
    
    func showRemovalUI(show: Bool) {
        doneRemovingBtn.isHidden = !show
        removeBtn.isHidden = !show
        
        if show {
            nextCardImageView.image = UIImage(named: spotImageName)
        }
    }
    
    func resetCardIndexes() {
        firstSelectedCardIndexPath = nil
        secondSelectedCardIndexPath = nil
    }
    
    func finishedPlacingCard() {
        checkAvailability()
        
        // TODO: Add winning game option
        
        if isGameOver() {
            setGameStatus(status: .gameOver)
        } else {
            if isBoardFull() {
                setGameStatus(status: .removing)
            } else {
                setGameStatus(status: .placing)
            }
        }
        
    }

    func removeAllCards() {
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            cell.removeCard()
        }
    }
    
    func markAllCardAsNotSelected() {
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            cell.setNotSelected()
        }
    }
    
    func markCardAsSelected(at indexPath: IndexPath) {
        if let cell = spotsCollectionView.cellForItem(at: indexPath) as? CardCollectionViewCell {
            cell.setSelected()
        }
    }

    // MARK: - Game Logic Functions

    // Game Logic
    func initializeGame() {
        setGameStatus(status: .placing)
        
        markAllCardAsNotSelected()
        removeAllCards()
        
        // Get deck
        deck = model.getTestDeck()
        deck = model.getCards()
        deck.shuffle()
        
        // Handle first card
        getNextCard()
        updateNextCardImage()
    }
    
    // Game Logic
    func playTurn(with indexPath: IndexPath) {
        let cell = spotsCollectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
            
            
            if gameStatus == .placing {
                // What to do when a spot is selected
                if canPutCard(nextCard, at: indexPath) {
                    
                    // Put the card in the spot and go to the next card
                    animateCard(card: nextCard, to: indexPath)
                    cell.setCard(nextCard)
                    getNextCard()
                    
                }
                finishedPlacingCard()
            } else if gameStatus == .removing {
                
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
                
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            let allowedRanks = getAllowedRanksByPosition(indexPath: cell.indexPath!)
            if let card = cell.card {
                let cardRank = card.rank!
                if allowedRanks == .jacks && cardRank != .jack {
                    return false
                }
                if allowedRanks == .queens && cardRank != .queen {
                    return false
                }
                if allowedRanks == .kings && cardRank != .king {
                    return false
                }
            } else if allowedRanks != .notRoyal{
                return false
            }
        }
        
        return true
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
        if deck.count > 0 {
            nextCard = deck.remove(at: 0)
            updateNextCardImage()
        } else {
            if isGameWon() {
                setGameStatus(status: .won)
            } else if isGameOver() {
                setGameStatus(status: .gameOver)
            }
        }
    }
    
    // Game Logic?
    func updateNextCardImage() {
        if gameStatus == .placing || gameStatus == .removing {
            nextCardImageView.image = UIImage(named: "\(nextCard.imageName).jpg")
        } else {
//            nextCardImageView.image = UIImage(named: spotImageName)
        }
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
    
    func gameOver() {
        showAlert("Game Over", "You've lost")
        updateNextCardImage()
    }
    
    func gameWon() {
        showAlert("Congratulations!", "You won")
        updateNextCardImage()
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

