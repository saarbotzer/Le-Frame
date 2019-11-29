//
//  ViewController.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class GameVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate {

    // MARK: Properties & Declerations
    // IBOutlets
    @IBOutlet weak var spotsCollectionView: UICollectionView!
    @IBOutlet weak var nextCardImageView: UIImageView!
    @IBOutlet weak var doneRemovingBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cardsLeftLabel: UILabel!
    @IBOutlet weak var removalSumLabel: UILabel!
    @IBOutlet weak var removalSumTitleLabel: UILabel!
    
    // Spots available by rank
    var kingsAvailable : Int = 4
    var queensAvailable : Int = 4
    var jacksAvailable : Int = 4
    var spotsAvailable : Int = 16
    
    // Game Data
    var model = CardModel()
    var deck = [Card]()

    var nextCard = Card()
    var firstSelectedCardIndexPath: IndexPath?
    var secondSelectedCardIndexPath: IndexPath?
    var cardsLeft : Int?
    
    var gameStatus = GameStatus.placing
    
    // Game Stats
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var deckHash : String?
    var gameID : UUID?
    var didWin : Bool = false
    var loseReason : String = ""
    var restartAfter : Bool?
    var startTime : Date?
    
    var statsAdded : Bool = false
    
    // Timer
    var timer: Timer?
    var secondsPassed: Int = 0
    
    // Settings
    let defaults = UserDefaults.standard
    var gameSumMode : SumMode = .ten
    
    // Sounds
    var player: AVAudioPlayer?
    
    
    // UI
    let disabledColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    
    // Hints
    var hintToShow : Bool = false
    var hintsUsed : Int = 0
    var blockedCardTaps : Int = 0
    var lastTapTime : Date?
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        spotsCollectionView.delegate = self
        spotsCollectionView.dataSource = self
        
        updateUI()
        
        initializeGame()
    }
    
    // MARK: - Gameflow Functions
    /**
     Starts a new game.
     */
    func initializeGame() {
        
        gameSumMode = getSumSetting()
        removalSumLabel.text = "\(gameSumMode.getRawValue())"
        
        setGameStatus(status: .placing)
        
        markAllCardAsNotSelected()
        removeAllCards()
        
        // Get deck
        deck = model.getRoyalTestDeck()
//        deck = model.getRegularTestDeck()
        deck = model.getCards()
        deck.shuffle()
        
        deckHash = model.getDeckHash(deck: deck)
        cardsLeft = deck.count
        
        gameID = UUID()
        statsAdded = false
        secondsPassed = 0
        
        // Handle first card
        getNextCard()
        updateNextCardImage()
        updateCardsLeftLabel()
        addTimer()
        
        
        startTime = Date()
    }
    
    /**
     Gets the setted SumMode (10/11) for the current game from the user defaults.
     - Returns: The setted SumMode
     */
    func getSumSetting() -> SumMode {
        let savedValue = defaults.integer(forKey: "SumMode")
        if savedValue == 11 {
            return .eleven
        } else {
            return .ten
        }
    }
    
    func getHintsSetting() -> Bool {
        let savedValue = defaults.bool(forKey: "ShowHintsOn")
        return savedValue
    }
    
    func getSoundSetting() -> Bool {
        let savedValue = defaults.bool(forKey: "SoundsOn")
        return savedValue
    }
    
    
    /**
     Checks whether the next card can be placed at a spot on the board.
     
     - Parameter card: The card to check
     - Parameter indexPath: The designated spot to place the card at
     
     - Returns: True if the card can be placed at the spot, false otherwise
     */
    func canPutCard(_ card: Card, at indexPath: IndexPath) -> Bool {
        // If the spot is empty then check whether the spot position and the card rank fit
        
        let cell = getSpot(at: indexPath)
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
    
    /**
     Checks whether the game was completed and the user have won.
     
     - Returns: True if the user won the game, false otherwise
     */
    func isGameWon() -> Bool {

        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            
            let allowedRanks = getAllowedRanksByPosition(indexPath: cell.indexPath!)
            // If the spot contains a card that does not match it's designated rank, the function returns false.
            if let card = cell.card {
                let cardRank = card.rank!
                if (allowedRanks == .jacks && cardRank != .jack) || (allowedRanks == .queens && cardRank != .queen) || (allowedRanks == .kings && cardRank != .king) || (allowedRanks == .notRoyal) {
                    return false
                }
            // If there is no card at the spot and it is a royal spot, the function returns false.
            } else if allowedRanks != .notRoyal{
                return false
            }
        }
        
        return true
    }
    
    /**
     Checks whether the user lose. It's using the nextCard so must be called after a turn
     
     - Returns: True if the game is over, false otherwise
     */
    func isGameOver() -> Bool {
        
        let boardFull = isBoardFull()
        let pairsToRemove = checkForPairs()
        let nextCardRank = nextCard.rank!
        
        // If the board is full and there are no cards to remove
        if boardFull && !pairsToRemove {
            return true
        }
        // If the next card is royal and all of the relevant spots are taken
        if !boardFull && nextCardRank == .jack && jacksAvailable == 0 {
            return true
        }
        if !boardFull && nextCardRank == .queen && queensAvailable == 0 {
            return true
        }
        if !boardFull && nextCardRank == .king && kingsAvailable == 0 {
            return true
        }
        
        return false
    }
    
    // TODO: Maybe change AllowedRanks to "DesignatedRanks" or something like it
    /**
     Checks for a certain IndexPath which type of cards should be placed.
     - Parameter indexPath: The spot's IndexPath
     - Returns: The appropriate AllowedRanks for the spot
     */
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
    
    
    // TODO: Move function to appropriate place and improve function
    func updateUI() {
        spotsCollectionView.backgroundColor = UIColor.clear
        
        doneRemovingBtn.setTitleColor(UIColor.white, for: .normal)
        doneRemovingBtn.setTitleColor(disabledColor, for: .disabled)
        
        removeBtn.setTitleColor(UIColor.white, for: .normal)
        removeBtn.setTitleColor(disabledColor, for: .disabled)

        updateTabBarUI()
    }
    
    // TODO: Move function to appropriate place
    func updateTabBarUI() {
        tabBar.layer.borderWidth = 0.50
        tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBar.clipsToBounds = true
        
        tabBar.backgroundColor = UIColor.clear
        
        // Changing the tabBar items' color to black
        for item in tabBar.items! {
//            item.image = item.image?.withRenderingMode(.alwaysOriginal)
            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        }
        
        
        // TODO: Move to another place
        tabBar.delegate = self
    }
    
    // MARK: - IBActions
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 1:
            performSegue(withIdentifier: "goToSettings", sender: nil)
        case 2:
            showHints(hintType: .tappedHintButton)
        case 3:
            showAlert("New Game?", "Are you sure you want to restart?")
        default:
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.tabBar.selectedItem = nil
        }
        
    }
    
    
    
    
    /** Called when **Remove** button is pressed.
     The function checks whether one card or two cards are selected, and removes them if they are summed to 10 or 11 (depending on the mode).
    */
    @IBAction func removePressed(_ sender: Any) {
        // Validity checks (no index paths, same index path)
        // TODO: maybe change ifs to if lets
        
        // Option 1 - Only one card is selected
        if firstSelectedCardIndexPath != nil && secondSelectedCardIndexPath == nil {
            let firstCardCell = getSpot(at: firstSelectedCardIndexPath!)
            let firstCard = firstCardCell.card!
            // If the card is 10 - remove
            if gameSumMode == .ten && firstCard.rank! == .ten {
                playSound(named: "card-flip-2.wav")
                firstCardCell.removeCard()
                enableDoneRemoving()
            }
        // Option 2 - Two cards are selected
        } else if firstSelectedCardIndexPath != nil && secondSelectedCardIndexPath != nil {
            let firstCardCell = getSpot(at: firstSelectedCardIndexPath!)
            let firstCard = firstCardCell.card!
            
            let secondCardCell = getSpot(at: secondSelectedCardIndexPath!)
            let secondCard = secondCardCell.card!
            
            // If the cards match - remove
            if firstCard.rank!.getRawValue() + secondCard.rank!.getRawValue() == gameSumMode.getRawValue() {
                playSound(named: "card-flip-2.wav")
                firstCardCell.removeCard()
                secondCardCell.removeCard()
                enableDoneRemoving()
            }
        }
        resetCardIndexes()
        markAllCardAsNotSelected()
    }
    
    /** Called when **Done** button is pressed.
     Switches between removing and placing game modes and deselects all cards.
     */
    @IBAction func doneRemovingPressed(_ sender: Any) {
        finishedTurn()
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
        switch gameStatus {
        case .placing:
            placeCard(at: indexPath)
            finishedTurn()
//            finishedPlacingCard()
        case .removing:
            selectCardForRemoval(at: indexPath)
        case .gameOver:
            // TODO: What to do when a card was tapped when gameOver/Won
            gameOver()
        case .won:
            // TODO: What to do when a card was tapped when gameOver/Won
            gameWon()
        default:
            
            return
        }
        
//        print("Next card: \(nextCard.imageName)")
        
        
        
//        if gameStatus != .removing {
//            if isGameOver() {
//                setGameStatus(status: .gameOver)
//            } else if isGameWon() {
//                setGameStatus(status: .won)
//            }
//        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
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
        let cell = getSpot(at: indexPath)
        
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
            self.stopTimer()
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
        
        lastTapTime = Date()
        
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
        removeBtn.isEnabled = false
        doneRemovingBtn.isEnabled = false
        removalSumLabel.isHidden = !show
        removalSumTitleLabel.isHidden = !show
        removalSumLabel.adjustsFontSizeToFitWidth = true
        removalSumLabel.minimumScaleFactor = 0.2
        
        if show {
            nextCardImageView.image = UIImage(named: spotImageName)
        }
    }
    
    func enableDoneRemoving() {
        if !checkForPairs(){
            doneRemovingBtn.isEnabled = true
        }
    }
    
    func resetCardIndexes() {
        firstSelectedCardIndexPath = nil
        secondSelectedCardIndexPath = nil
    }
    
    func isNextCardBlocked() -> Bool {
        if cardsLeft == 0 {
            return false
        }
        
        if let nextCardRank = nextCard.rank {
            if nextCardRank == .jack && jacksAvailable == 0 {
                return true
            } else if nextCardRank == .queen && queensAvailable == 0{
                return true
            } else if nextCardRank == .king && kingsAvailable == 0 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func finishedTurn() {
        
        
        checkAvailability()
        
//        print(gameStatus)
        
        let boardFull = isBoardFull()
        let cardsToRemove = checkForPairs()
        let nextCardIsBlocked = isNextCardBlocked()
        
        updateCardsLeftLabel()
        
        if boardFull {
            if cardsToRemove {
                setGameStatus(status: .removing)
            } else {
                setGameStatus(status: .gameOver)
            }
        } else if nextCardIsBlocked {
            setGameStatus(status: .gameOver)
        } else if gameStatus == .removing {
            setGameStatus(status: .placing)
        }
        if isGameWon() {
            setGameStatus(status: .won)
        }
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
            cell.setSelected(selected: false)
        }
    }
    
    func markCardAsSelected(at indexPath: IndexPath) {
        if let cell = spotsCollectionView.cellForItem(at: indexPath) as? CardCollectionViewCell {
            cell.setSelected(selected: true)
        }
    }

    // MARK: - Game Logic Functions

    // Game Logic
    
    
    /**
     Checks if the card can be put at the spot and does it if so.
     - Parameter indexPath: The spot's IndexPath
     */
    func placeCard(at indexPath: IndexPath) {
        let cell = getSpot(at: indexPath)

        // Start hints procedure (show hints after some time with no taps)
        lastTapTime = Date()
        let timeToShowHint = 3.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeToShowHint) {
            if let lastTapTime = self.lastTapTime{
                if Date().timeIntervalSince(lastTapTime) > timeToShowHint {
                    print("Now")
                    self.showHints(hintType: .waitedTooLong)
                }
            }
        }
        
        if canPutCard(nextCard, at: indexPath) {
            // Put the card in the spot and go to the next card
            playSound(named: "card-flip-1.wav")

            animateCard(card: nextCard, to: indexPath)
            blockedCardTaps = 0
            cell.setCard(nextCard)
            getNextCard()
            cardsLeft = cardsLeft! - 1
        } else {
            blockedCardTaps += 1
            
            if blockedCardTaps > 2 {
                self.showHints(hintType: .tappedTooManyTimes)
            }
        }
    }
    
    /**
     Checks what card are already selected and selects/deselects accordingly.
     
     - Parameter indexPath: The tapped spot's IndexPath
     */
    func selectCardForRemoval(at indexPath: IndexPath) {
        let tappedSpot = getSpot(at: indexPath)
        
        removeBtn.isEnabled = true
        
        // In case of pressing an empty spot in removal mode
        if tappedSpot.isEmpty {
            return
        }
        
        // If this is the first selected card, select the tapped card
        if firstSelectedCardIndexPath == nil {
            firstSelectedCardIndexPath = indexPath
            secondSelectedCardIndexPath = nil
            markCardAsSelected(at: firstSelectedCardIndexPath!)
        } else {
            // If the tapped card is already selected, deselect it
            if firstSelectedCardIndexPath == indexPath {
                firstSelectedCardIndexPath = nil
                secondSelectedCardIndexPath = nil
                markAllCardAsNotSelected()
            }
            // If no second card is selected, select the tapped card
            else if secondSelectedCardIndexPath == nil {
                secondSelectedCardIndexPath = indexPath
                markCardAsSelected(at: secondSelectedCardIndexPath!)
            }
            // If two cards are already selected, deselect them and select the tapped card
            else {
                markAllCardAsNotSelected()
                firstSelectedCardIndexPath = indexPath
                secondSelectedCardIndexPath = nil
                markCardAsSelected(at: firstSelectedCardIndexPath!)
            }
        }
    }
    
    // Game Logic
    func getNextCard() {
        if deck.count > 0 {
            nextCard = deck.remove(at: 0)
            
            updateNextCardImage()
        }
    }
    
    func updateCardsLeftLabel() {
        cardsLeftLabel.text = "CARDS LEFT: \(cardsLeft ?? 0)"
    }
    
    // Game Logic?
    func updateNextCardImage() {
        if let image = UIImage(named: "\(nextCard.imageName).jpg") {
            nextCardImageView.image = image
        }
//        if gameStatus == .placing || gameStatus == .removing {
//            nextCardImageView.image = UIImage(named: "\(nextCard.imageName).jpg")
//        } else {
////            nextCardImageView.image = UIImage(named: spotImageName)
//        }
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
        if allNonRoyalValues.contains(10) && gameSumMode == .ten{
            return true
        }
        for i in 0..<allNonRoyalValues.count {
            for j in i+1..<allNonRoyalValues.count {
                if allNonRoyalValues[i] + allNonRoyalValues[j] == gameSumMode.getRawValue() {
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
        
        stopTimer()
        showAlert("Game Over", "You've lost")
        didWin = false
        loseReason = getLoseReason()
        print(loseReason)
        updateNextCardImage()
        
        addStats()
    }
    
    func getLoseReason() -> String {
        if let nextCardRank = nextCard.rank {
            if nextCardRank == .jack && jacksAvailable == 0 {
                return "noEmptyJackSpots"
            }
            if nextCardRank == .queen && queensAvailable == 0 {
                return "noEmptyQueenSpots"
            }
            if nextCardRank == .king && kingsAvailable == 0 {
                return "noEmptyKingSpots"
            }
        }
        if isBoardFull() && !checkForPairs() {
            return "noCardsToRemove"
        }
        return "unknown"
    }
    
    func gameWon() {
        stopTimer()
        showAlert("Congratulations!", "You won")
        didWin = true
//        updateNextCardImage()
        nextCardImageView.image = UIImage(named: spotImageName)
        
        addStats()
    }

    // Game Logic
    func checkAvailability() {
        kingsAvailable = 0
        queensAvailable = 0
        jacksAvailable = 0
        spotsAvailable = 0
        
        for spot in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            let indexPath = spot.indexPath!
            let allowedRanks = getAllowedRanksByPosition(indexPath: indexPath)
            if spot.isEmpty {
                switch allowedRanks {
                case .jacks:
                    jacksAvailable += 1
                case .queens:
                    queensAvailable += 1
                case .kings:
                    kingsAvailable += 1
                default:
                    spotsAvailable += 1
                }
            }
            spotsAvailable = spotsAvailable + jacksAvailable + queensAvailable + kingsAvailable
        }
    }
    
    // MARK: Misc Functions
    
    func addTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    @objc func timerElapsed() {
        secondsPassed += 1
        
        let hours = secondsPassed / 3600
        let minutes = secondsPassed / 60 % 60
        let seconds = secondsPassed % 60
        
        var timeString = ""
        
        if hours > 0 {
            timeString = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            timeString = String(format: "%02i:%02i", minutes, seconds)
        }
        
        timeLabel.text = "TIME: \(timeString)"
        
        // Stop the timer
//        timer?.invalidate()
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    // MARK: - Data Model Functions
    
    func addStats() {
        if statsAdded {
            return
        }
        let gameRow: Game = Game(context: context)
        gameRow.gameID = gameID
        gameRow.deck = deckHash
        gameRow.didWin = didWin
        gameRow.duration = Int16(secondsPassed)
        gameRow.loseReason = loseReason
        gameRow.nofCardsLeft = Int16(cardsLeft!)
        gameRow.nofJacksPlaced = getNumberOfCardsPlaced(withRank: .jack)
        gameRow.nofKingsPlaced = getNumberOfCardsPlaced(withRank: .king)
        gameRow.nofQueensPlaced = getNumberOfCardsPlaced(withRank: .queen)
        gameRow.nofHintsUsed = Int16(hintsUsed)
        
        // TODO: Check if restarted after, update row
        gameRow.restartAfter = false
        
        gameRow.startTime = startTime
        gameRow.sumMode = Int16(gameSumMode.getRawValue())
        
        saveStats()
    }
    
    func getNumberOfCardsPlaced(withRank rank: CardRank) -> Int16 {
        var nofCards : Int16 = 0
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            if let card = cell.card {
                if card.rank! == rank {
                    nofCards += 1
                }
            }
        }
        return nofCards
    }
    
    func saveStats() {
        do {
            try context.save()
            statsAdded = true
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    

}


extension GameVC {
    //MARK: Hints functions
    
    func showHints(hintType : HintType) {
        let isShowHints = getHintsSetting()
        if hintType != .tappedHintButton && !isShowHints {
            return
        }
        let hints = getHints()
        for indexPath in hints {
            hintCard(at: indexPath)
            hintsUsed += 1
        }
    }
    
    func hintCard(at indexPath: IndexPath) {
        let spot = getSpot(at: indexPath)
        
        spot.setHinted(on: true)
    }
    
    func getHints() -> [IndexPath] {
        var indexPathsToHint = [IndexPath]()
        
        if gameStatus == .placing {
            if let nextCardRank = nextCard.rank {
                if nextCardRank.getRawValue() <= 10 {
                    // center
                    let emptyCenterSpots = getEmptySpots(atCenter: true)
                    if emptyCenterSpots.count > 0 {
                        indexPathsToHint = emptyCenterSpots
                    } else {
                        // royal with most empty spot
                        let emptyRoyalSpots = getEmptySpots(atCenter: false)
                        indexPathsToHint = emptyRoyalSpots
                    }
                } else {
                    // TODO: Hint appropriate cell for each royal rank
                    let rankIndexPaths = Utilities.getSpots(forRank: nextCardRank)
                    let emptyRankSpots = filterSpots(indexPaths: rankIndexPaths, empty: true)
                    indexPathsToHint = emptyRankSpots
                }
            }
            if indexPathsToHint.count > 0 {
                indexPathsToHint = [indexPathsToHint.randomElement()!]
            }
        } else if gameStatus == .removing {
            indexPathsToHint = getCardsToRemove()
        }
        
        return indexPathsToHint
    }
    
    func getCardsToRemove() -> [IndexPath] {
        var cardsSpots = [IndexPath]()
        
        var allPairs = [[IndexPath]]()
        
        for spot1 in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            if let card1 = spot1.card {
                let card1RankValue = card1.rank!.getRawValue()
                if card1RankValue < 11 {
                    if card1RankValue == gameSumMode.getRawValue() {
                        return [spot1.indexPath!]
                    }
                    for spot2 in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
                        if let card2 = spot2.card {
                            let card2RankValue = card2.rank!.getRawValue()
                            if card2RankValue < 11 && spot1 != spot2 {
                                if card1RankValue + card2RankValue == gameSumMode.getRawValue() {
                                    allPairs.append([spot1.indexPath!, spot2.indexPath!])
                                }
                            }
                        }
                    }
                }
            }
        }
        if let randomPair = allPairs.randomElement() {
            cardsSpots = randomPair
        }
        return cardsSpots
    }
    
    func getEmptySpots(atCenter: Bool) -> [IndexPath] {
        var emptySpots = [IndexPath]()
        
        if atCenter {
            let indexPaths = Utilities.getSpots(forRank: .ace)
            
            emptySpots = filterSpots(indexPaths: indexPaths, empty: true)
            return emptySpots
            
        } else {
            let jackIndexPaths = Utilities.getSpots(forRank: .jack)
            let emptyJackSpots = filterSpots(indexPaths: jackIndexPaths, empty: true)
            let queenIndexPaths = Utilities.getSpots(forRank: .queen)
            let emptyQueenSpots = filterSpots(indexPaths: queenIndexPaths, empty: true)
            let kingIndexPaths = Utilities.getSpots(forRank: .king)
            let emptyKingSpots = filterSpots(indexPaths: kingIndexPaths, empty: true)
            
            
            // To find if one of the royal ranks has a larger number of empty spots
            if emptyJackSpots.count > emptyQueenSpots.count && emptyJackSpots.count > emptyKingSpots.count {
                emptySpots = emptyJackSpots
                return emptySpots
            } else if emptyQueenSpots.count > emptyJackSpots.count && emptyQueenSpots.count > emptyKingSpots.count {
                emptySpots = emptyQueenSpots
                return emptySpots
            } else if emptyKingSpots.count > emptyJackSpots.count && emptyKingSpots.count > emptyQueenSpots.count {
                emptySpots = emptyKingSpots
                return emptySpots
            }
            
//            emptySpots = emptyKingSpots + emptyQueenSpots + emptyJackSpots
            // If two or more royal ranks have the same number of empty spots
            
            let placedJacks = getNumberOfPlacedCards(forRank: .jack)
            let placedQueens = getNumberOfPlacedCards(forRank: .queen)
            let placedKings = getNumberOfPlacedCards(forRank: .king)

            if emptyJackSpots.count == emptyQueenSpots.count && emptyJackSpots.count == emptyKingSpots.count {
                // Find rank with most placed royal cards out of the three ranks
                if placedJacks > placedQueens && placedJacks > placedKings {
                    return emptyJackSpots
                } else if placedQueens > placedJacks && placedQueens > placedKings {
                    return emptyQueenSpots
                } else if placedKings > placedJacks && placedKings > placedQueens {
                    return emptyKingSpots
                }
                // If two ranks have the same number of placed royal cards
                if placedJacks == placedQueens && placedJacks == placedKings {
                    return emptyJackSpots + emptyQueenSpots + emptyKingSpots
                } else if placedJacks == placedQueens {
                    return emptyJackSpots + emptyQueenSpots
                } else if placedKings == placedQueens {
                    return emptyKingSpots + emptyQueenSpots
                } else if placedJacks == placedKings {
                    return emptyJackSpots + emptyKingSpots
                }
            } else if emptyJackSpots.count == emptyQueenSpots.count {
                // Find rank with most placed royal cards out of jacks and queens
                if placedJacks == placedQueens {
                    return emptyJackSpots + emptyQueenSpots
                } else if placedJacks > placedQueens {
                    return emptyJackSpots
                } else {
                    return emptyQueenSpots
                }
            } else if emptyQueenSpots.count == emptyKingSpots.count {
                // Find rank with most placed royal cards out of kings and queens
                if placedKings == placedQueens {
                    return emptyKingSpots + emptyQueenSpots
                } else if placedKings > placedQueens {
                    return emptyKingSpots
                } else {
                    return emptyQueenSpots
                }
            } else if emptyJackSpots.count == emptyKingSpots.count {
                // Find rank with most placed royal cards out of jacks and kings
                if placedKings == placedJacks {
                    return emptyKingSpots + emptyJackSpots
                } else if placedKings > placedJacks {
                    return emptyKingSpots
                } else {
                    return emptyJackSpots
                }
            }
            
        }
        
        return emptySpots
    }
    
    func getNumberOfPlacedCards(forRank rank: CardRank) -> Int {
        var placedCards = 0
        let spotsIndexPaths = Utilities.getSpots(forRank: rank)
        for indexPath in spotsIndexPaths {
            let spot = getSpot(at: indexPath)
            if spot.card?.rank == rank {
                placedCards += 1
            }
        }
        return placedCards
    }
    
    func isSpotEmpty(indexPath: IndexPath) -> Bool {
        let spot = getSpot(at: indexPath)
        return spot.isEmpty
    }
    
    func filterSpots(indexPaths: [IndexPath], empty: Bool) -> [IndexPath] {
        return indexPaths.filter { (indexPath) -> Bool in
            if empty {
                return isSpotEmpty(indexPath: indexPath)
            } else {
                return !isSpotEmpty(indexPath: indexPath)
            }
        }
    }
    
    func getSpot(at indexPath: IndexPath) -> CardCollectionViewCell {
        return spotsCollectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
    }
    
    func getCard(at indexPath: IndexPath) -> Card? {
        let spot = getSpot(at: indexPath)
        return spot.card
    }
}


extension GameVC {
    
    func playSound(named soundFileFullName: String) {
        
        let soundsOn = getSoundSetting()
        if !soundsOn {
            return
        }

        let soundFileName = String(soundFileFullName.split(separator: ".")[0])
        let soundFileExtension = String(soundFileFullName.split(separator: ".")[1])
        
        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: soundFileExtension) else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}
