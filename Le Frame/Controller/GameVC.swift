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
import Firebase

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
    @IBOutlet weak var bottomView: UIView!
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
    var removedCards : [[Card]] = [[Card]]()
    
    var gameStatus: GameStatus = .placing
    
    // Game Stats
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var deckString : String?
    var gameID : UUID = UUID()
    var didWin : Bool = false
    var gameLoseReason : LoseReason = .unknown
    var restartAfter : Bool = false
    var startTime : Date?
    
    var statsAdded : Bool = false
    
    // Timer
//    var timer: Timer?
    
    var timer: Timer = Timer()
//    var secondsPassed: Int = 0
    
    // Settings
    let defaults = UserDefaults.standard
    
    // Sounds
    var player: AVAudioPlayer?
    
    var confettiEmitter = CAEmitterLayer()
    
    // UI
    let disabledColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    var cardHeight : CGFloat = 0
    var cardWidth : CGFloat = 0
    var cellSpacing : CGFloat = 10
    
    // Hints
    var hintToShow : Bool = false
    var hintsUsed : Int = 0
    var blockedCardTaps : Int = 0
    var lastTapTime : Date?
    
    
    
    // MARK: - ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        // Un-comment to view onboarding screen every time
//        defaults.set(false, forKey: "firstGamePlayed")
        
        
        setDelegates()
        
        updateUI()
        
        startNewGame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let viewingMode = getViewingMode()
        if viewingMode == .onboarding {
            performSegue(withIdentifier: "goToHowTo", sender: nil)
            defaults.set(true, forKey: "firstGamePlayed")
            
            // TODO: Verify that this is a good place and a way to create uuids
            defaults.set(UUID().uuidString, forKey: "uuid")
        }
    }
    
    func getViewingMode() -> OnboardingViewingMode {
        let firstGame = !defaults.bool(forKey: "firstGamePlayed")
        
        if firstGame {
            return .onboarding
        } else {
            return .howTo
        }
    }
    
    func setDelegates() {
        spotsCollectionView.delegate = self
        spotsCollectionView.dataSource = self
        tabBar.delegate = self
    }
    
    // MARK: - UI Functions
    
    /**
     Gathers all UI functions for initializing the views
     */
    func updateUI() {
        updateViews()
        updateTabBarUI()
    }
    
    /**
     Updates the appearance of the spots grid and the bottom view.
     */
    func updateViews() {
        let totalContentHeight = bottomView.frame.height + spotsCollectionView.frame.height
        let contentRowHeight = totalContentHeight / 5
        
        // Spots grid
        spotsCollectionView.frame = CGRect(x: spotsCollectionView.frame.minX, y: spotsCollectionView.frame.minY, width: spotsCollectionView.frame.width, height: contentRowHeight * 4)
        spotsCollectionView.backgroundColor = UIColor.clear
        
        // Bottom view
        bottomView.frame = CGRect(x: bottomView.frame.minX, y: bottomView.frame.minY, width: bottomView.frame.width, height: contentRowHeight)
    
        
        let doneIcon = doneRemovingBtn.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        doneRemovingBtn.setImage(doneIcon, for: .normal)

        doneRemovingBtn.setTitleColor(UIColor.white, for: .normal)
        doneRemovingBtn.tintColor = .white
        doneRemovingBtn.setTitleColor(disabledColor, for: .disabled)
        
        let removeIcon = removeBtn.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        removeBtn.setImage(removeIcon, for: .normal)
        removeBtn.tintColor = .white
        removeBtn.setTitleColor(UIColor.white, for: .normal)
        removeBtn.setTitleColor(disabledColor, for: .disabled)
    }
    
    
    /**
     Updates the TabBar UI
     */
    func updateTabBarUI() {
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBar.clipsToBounds = true
        
        tabBar.backgroundColor = UIColor.clear
        
        // Changing the tabBar items' color to black
        for item in tabBar.items! {
            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        }
    }
    
    /**
     Switches between showing and hiding the removal mode UI
     
     - Parameter show: True if show removal mode UI, false otherwise
     */
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
    
    /**
     Enables the Done Removing button
     */
    func enableDoneRemoving() {
        if !checkForPairs(){
            doneRemovingBtn.isEnabled = true
        }
    }
    
    // MARK: - Settings Getters
    
    /**
     Gets the setted SumMode (10/11) for the current game from the user defaults.
     
     - Returns: The setted SumMode
     */
    func getSumSetting() -> SumMode {
        let settingKey = SettingKey.sumMode
        let savedValue = defaults.integer(forKey: settingKey.getRawValue())
        if savedValue == 11 {
            return .eleven
        } else {
            return .ten
        }
    }
    
    /**
     Gets the setted hints settings (whether to show hints or not)
     
     - Returns: True if show hints, false otherwise
     */
    func getHintsSetting() -> Bool {
        let settingKey = SettingKey.showHints
        let savedValue = defaults.bool(forKey: settingKey.getRawValue())
        return savedValue
    }
    
    /**
     Gets the setted sounds settings
     
     - Returns: True if play sounds, false otherwise
     */
    func getSoundSetting() -> Bool {
        let settingKey = SettingKey.soundsOn
        let savedValue = defaults.bool(forKey: settingKey.getRawValue())
        return savedValue
    }
    
    // MARK: - Game Flow
    
    
    
    
    
    
    
    // MARK: - IBActions
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 1:
            performSegue(withIdentifier: "goToSettings", sender: nil)
        case 2:
            if isGameWon() {
                gameWon(toAddStats: false)
            } else if isGameOver() {
                gameOver(toAddStats: false)
            }
            showHints(hintType: .tappedHintButton)
        case 3:
            showAlert(title: "New Game?", message: "Are you sure you want to start a new game?", dismissText: "Nevermind", confirmText: "Yes")
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
        
        var newlyRemovedCards = [Card]()
        
        // Option 1 - Only one card is selected
        if firstSelectedCardIndexPath != nil && secondSelectedCardIndexPath == nil {
            let firstCardCell = getSpot(at: firstSelectedCardIndexPath!)
            let firstCard = firstCardCell.card!
            // If the card is 10 - remove
            if gameSumMode == .ten && firstCard.rank! == .ten {
                playSound(named: "card-flip-2.wav")
                haptic(of: .removeSuccess)
                newlyRemovedCards.append(firstCard)
                firstCardCell.removeCard()
                enableDoneRemoving()
                removeBtn.isEnabled = false
            } else {
                haptic(of: .removeError)
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
                haptic(of: .removeSuccess)
                newlyRemovedCards.append(firstCard)
                newlyRemovedCards.append(secondCard)
                firstCardCell.removeCard()
                secondCardCell.removeCard()
                enableDoneRemoving()
                removeBtn.isEnabled = false
            } else {
                haptic(of: .removeError)
            }
        }
        
        removedCards.append(newlyRemovedCards)
        resetCardIndexes()
        markAllCardAsNotSelected()
        finishedRemovingCard()
    }
    
    
    /** Called when **Done** button is pressed.
     Switches between removing and placing game modes and deselects all cards.
     */
    @IBAction func doneRemovingPressed(_ sender: Any) {
        finishedPlacingCard()
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
            finishedPlacingCard()
        case .removing:
            selectCardForRemoval(at: indexPath)
        case .gameOver:
            gameOver(toAddStats: false)
        case .won:
            gameWon(toAddStats: false)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
//        let totalCardWidth: CGFloat = cardWidth * 4
        let gridWidth = collectionView.frame.width
        let spacing: CGFloat = (gridWidth - (4 * cardWidth)) / 4
//        let totalSpacingWidth: CGFloat = spacing * (4 - 1)
        
        let edgeInsets = (self.view.frame.size.width - (4 * cardWidth)) / (4 + 1)
        
        return UIEdgeInsets(top: 5.0, left: edgeInsets, bottom: 5.0, right: edgeInsets)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let gridWidth = collectionView.frame.width
//        let spacing = (gridWidth - (4 * cardWidth)) / 4
        
        cardHeight = collectionView.frame.height / 4 - 10
        cardWidth = cardHeight / 3 * 2
        

        return CGSize(width: cardWidth, height: cardHeight)
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
    func showAlert(title: String, message: String, dismissText: String, confirmText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let restartAction = UIAlertAction(title: confirmText, style: .default) { (action) in
            self.stopTimer()
            self.restartAfter = true
            self.addStats()
            self.startNewGame()
        }
        let okAction = UIAlertAction(title: dismissText, style: .cancel, handler: nil)

        alert.addAction(okAction)
        alert.addAction(restartAction)

        present(alert, animated: true, completion: nil)
        
        /*
        let confirmButton = AlertButton(title: "Yes", action: newGame, titleColor: .white, backgroundColor: .lightGray)
        let dismissButton = AlertButton(title: "Nevermind", action: nil, titleColor: .white, backgroundColor: .lightGray)
        
        let alertPayload = AlertPayload(title: title, titleColor: .white, message: message, messageColor: .white, buttons: [confirmButton, dismissButton], backgroundColor: .green)

        Utilities.showAlert(payload: alertPayload, parentViewController: self)
         */
        
    }
    
    func newGame() {
        //TODO: Make it a new game
        stopTimer()
        startNewGame()
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
            gameFinished = true
            gameOver(toAddStats: true)
        case .won:
            showRemovalUI(show: false)
            gameFinished = true
            gameWon(toAddStats: true)
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
    
    func finishedPlacingCard() {
        
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
        } else if cardsLeft == 0 {
            setGameStatus(status: .removing)
        }
        if isGameWon() {
            setGameStatus(status: .won)
        }
    }
    
    /**
     Handles what happens after pressed remove.
     The function checks if it is the case of a full frame with middle cards that can't be removed (whilst no more cards in the deck) and if so it sets the game as over.
     */
    func finishedRemovingCard() {
        
        let cardsToRemove = getCardsToRemove()

        let cardsAtCenter = getEmptySpots(atCenter: true)
        
        if let cardsLeft = cardsLeft {
            if cardsLeft == 0 && cardsToRemove.count == 0 && cardsAtCenter.count != 4 {
                setGameStatus(status: .gameOver)
                nextCardImageView.image = UIImage(named: spotImageName)
            } else {
//                updateNextCardImage()
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
        let timeToShowHint = 10.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeToShowHint) {
            if let lastTapTime = self.lastTapTime {
                if Date().timeIntervalSince(lastTapTime) > timeToShowHint && self.gameStatus == .placing {
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
            haptic(of: .placeSuccess)
            
            getNextCard()
            cardsLeft = cardsLeft! - 1
        } else {
            haptic(of: .placeError)
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
        
        // In case of pressing an empty spot in removal mode
        if tappedSpot.isEmpty  || [CardRank.jack, CardRank.queen, CardRank.king].contains(tappedSpot.card?.rank){
            return
        }
        
        removeBtn.isEnabled = true
        
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
                removeBtn.isEnabled = false
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
        } else {
            nextCardImageView.image = UIImage(named: spotImageName)
//            setGameStatus(status: .won)
        }
    }
    
    func updateCardsLeftLabel() {
        cardsLeftLabel.text = "CARDS LEFT: \(cardsLeft ?? 0)"
    }
    
    // Game Logic?
    func updateNextCardImage() {
        // TODO: Don't change image to the previous card when there are no cards left
        if let image = UIImage(named: "\(nextCard.imageName).jpg") {
            nextCardImageView.image = image
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
    
    func gameOver(toAddStats: Bool) {
        
        stopTimer()
        playSound(named: "lose.wav")
        haptic(of: .gameOver)
        didWin = false
        gameLoseReason = getLoseReason()
        let loseReasonText = getLoseReasonText(loseReason: gameLoseReason)
        
        let statsText = getGameStatsText()
        let messageText = "\(loseReasonText)\n\n\(statsText)"
        showAlert(title: "Game Over", message: messageText, dismissText: "OK", confirmText: "Start a new game")
        
        if let cardsLeft = cardsLeft {
            if cardsLeft > 0 {
                updateNextCardImage()
            }
        }

        if toAddStats {
            addStats()
        }
    }
    
    func getGameStatsText() -> String {
        var cardsLeftText = ""
        if cardsLeft != nil && cardsLeft! > 0 {
            cardsLeftText = "Cards Left: \(cardsLeft!)"
        }
        
        let timeText = "Time: \(Utilities.formatSeconds(seconds: secondsPassed))"
        let statsText = "\(timeText)\n\(cardsLeftText)"
        return statsText
    }
    
    func getLoseReasonText(loseReason: LoseReason) -> String {
        switch loseReason {
        case .noEmptyJackSpots:
            return "The next card is a Jack and there are no available spots in the sides."
        case .noEmptyKingSpots:
            return "The next card is a King and there are no available spots in the corners."
        case .noEmptyQueenSpots:
            return "The next card is a Queen and there are no available spots in the top and bottom."
        case .noCardsToRemove:
            return "There aren't any cards that sum up to \(gameSumMode) to remove."
        default:
            return ""
        }
    }
    
    func getLoseReason() -> LoseReason {
        if !checkForPairs() {
            return .noCardsToRemove
        }
        
        if let nextCardRank = nextCard.rank {
            if nextCardRank == .jack && jacksAvailable == 0 {
                return .noEmptyJackSpots
            }
            if nextCardRank == .queen && queensAvailable == 0 {
                return .noEmptyQueenSpots
            }
            if nextCardRank == .king && kingsAvailable == 0 {
                return .noEmptyKingSpots
            }
        }
        return .unknown
    }
    
    func gameWon(toAddStats: Bool) {
        stopTimer()
        
        playSound(named: "win.wav")
        confetti()
        haptic(of: .win)
        didWin = true
        
        let statsText = getGameStatsText()
        let messageText = "Good job! You filled the frame with royal cards\n\n\(statsText)"
        
        showAlert(title: "You Won!", message: messageText, dismissText: "Great", confirmText: "Start a new game")
        
        nextCardImageView.image = UIImage(named: spotImageName)
        
        if toAddStats {
            addStats()
        }
    }

    // Game Logic
    func checkAvailability() {
        kingsAvailable = 0
        queensAvailable = 0
        jacksAvailable = 0
        spotsAvailable = 0
        
        for spot in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            let indexPath = spot.indexPath!
            let allowedRanks = getDesignatedRanksByPosition(indexPath: indexPath)
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
    
    // MARK: - Stats Functions
    
    /**
     Adds the game stats to the context.
     */
    func addStats() {
        
        let gameSavedStats = getStats(for: gameID)
        
        if let gameStatsToAdd = gameSavedStats {
            gameStatsToAdd.restartAfter = restartAfter
            
            let synced = uploadStats(forGame: gameStatsToAdd)
            gameStatsToAdd.synced = synced
        } else {
            let gameStatsToAdd = Game(context: context)
            gameStatsToAdd.gameID = gameID
            gameStatsToAdd.deck = deckString
            gameStatsToAdd.didWin = didWin
            gameStatsToAdd.duration = Int16(secondsPassed)
            gameStatsToAdd.loseReason = gameLoseReason.getRawValue()
            gameStatsToAdd.nofCardsLeft = Int16(cardsLeft!)
            gameStatsToAdd.nofJacksPlaced = Int16(getNumberOfCardsPlaced(withRank: .jack))
            gameStatsToAdd.nofKingsPlaced = Int16(getNumberOfCardsPlaced(withRank: .king))
            gameStatsToAdd.nofQueensPlaced = Int16(getNumberOfCardsPlaced(withRank: .queen))
            gameStatsToAdd.nofHintsUsed = Int16(hintsUsed)
            gameStatsToAdd.restartAfter = restartAfter
            gameStatsToAdd.startTime = startTime
            gameStatsToAdd.sumMode = Int16(gameSumMode.getRawValue())
            gameStatsToAdd.synced = false
            
            let synced = uploadStats(forGame: gameStatsToAdd)
            gameStatsToAdd.synced = synced
        }
        
        saveStats()
    }
    
    /**
     Save the stats that are staged in the context.
     */
    func saveStats() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    /**
     Gets the stats for a gameID
     
     - Parameter gameID: The gameID to get the stats for
     - Returns: The game object with all the stats
     */
    func getStats(for gameID: UUID) -> Game? {
        var gameRow: Game? = nil
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Game")
        fetchRequest.predicate = NSPredicate(format: "gameID = %@", gameID.uuidString)
        do {
            let results = try context.fetch(fetchRequest)
            if results.count == 1 {
                gameRow = results[0] as? Game
            } else if results.count > 1 {
                gameRow = results[0] as? Game
                // TODO: Delete other results if there is more than one
            }
        }
        catch {
            print(error)
        }
        return gameRow
    }
    
    func uploadStats(forGame game: Game?) -> Bool {
        var statsUploaded = false
        
        if let game = game {
            if game.gameID == nil {
                return false
            }
            
            let dataToAdd : [String: Any] = [
//                "userID": defaults.string(forKey: "uuid"),
                "deck": game.deck,
                "didWin": game.didWin,
                "duration": game.duration,
                "loseReason": game.loseReason,
                "numberOfCardsLeft": game.nofCardsLeft,
                "numberOfJacksPlaced": game.nofJacksPlaced,
                "numberOfKingsPlaced": game.nofKingsPlaced,
                "numberOfQueensPlaced": game.nofQueensPlaced,
                "numberOfHintsUsed": game.nofHintsUsed,
                "didRestartAfter": game.restartAfter,
                "startTime": game.startTime,
                "sumMode": game.sumMode,
                "synced": true
            ]
            
            let uuid = defaults.string(forKey: "uuid")

            var dataToAddUser = dataToAdd
            dataToAddUser["gameID"] = game.gameID!.uuidString
            
            var dataToAddGame = dataToAdd
            dataToAddGame["userID"] = uuid
            
            let gameDataUploaded = up(referenceString: "games/\(game.gameID!)", dataToAdd: dataToAddGame)
            let userDataUploaded = up(referenceString: "users/\(uuid!)/games/\(game.gameID!)", dataToAdd: dataToAddUser)
            statsUploaded = gameDataUploaded && userDataUploaded
        }
        return statsUploaded
    }
    
    func up(referenceString: String, dataToAdd: [String: Any]) -> Bool {
        var statsUploaded = false
        var ref = Firestore.firestore().document(referenceString)
        
        ref.setData(dataToAdd) { (err) in
            if let err = err {
                print("Error adding document: \(err)")
                statsUploaded = false
            } else {
//                print("Document added with ID: \(ref.documentID)")
                statsUploaded = true
            }
        }
        return statsUploaded
    }
    
    
    // MARK: - Helper Functions
    
    /**
     Checks for a certain IndexPath which type of cards should be placed.
     - Parameter indexPath: The spot's IndexPath
     - Returns: The appropriate AllowedRanks for the spot
     */
    func getDesignatedRanksByPosition(indexPath: IndexPath) -> DesignatedRanks {
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
    
    /**
     Gets the number of cards that are currently placed on the board
     
     - Parameter rank: The rank of which to count placed cards
     - Returns: The numebr of cards of the specified rank placed on the board
     */
    func getNumberOfCardsPlaced(withRank rank: CardRank) -> Int {
        var nofCards : Int = 0
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            if let card = cell.card {
                if card.rank! == rank {
                    nofCards += 1
                }
            }
        }
        return nofCards
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

// MARK: - Game Logic

extension GameVC {
    
    /**
     Starts a new game.
     */
    func startNewGame() {
            
        // Get game settings
        gameSumMode = getSumSetting()
        setGameStatus(status: .placing)
        
        restartAfter = false
        gameFinished = false
        gameID = UUID()
        startTime = Date()
        statsAdded = false
        secondsPassed = 0
        
        // UI
        removalSumLabel.text = "\(gameSumMode.getRawValue())"
        markAllCardAsNotSelected()
        removeAllCards()
        confettiEmitter.removeFromSuperlayer()
        
        // Get deck
        deck = model.getDeck(ofType: .regularDeck, random: true, from: nil, fullDeck: nil)
        deck = model.getDeck(ofType: .onlyRoyals, random: false, from: nil, fullDeck: nil)
//        deck = model.getDeck(ofType: .notRoyals, random: false, from: nil, fullDeck: nil)
//        deck = model.getDeck(ofType: .fromString, random: false, from: "h10c10c05h13c13d13s13h12c12d12s12h11c11d11s11", fullDeck: false)
        
        deckString = model.getDeckString(deck: deck)
        
        cardsLeft = deck.count
        
        print("Started new game \(gameID.uuidString)")
        
        // Handle first card
        getNextCard()
        updateNextCardImage()
        updateCardsLeftLabel()
        
        // Timer
        addTimer()
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
            
            let allowedRanks = getDesignatedRanksByPosition(indexPath: indexPath)
            
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
     Game is won if all royal cards are placed at appropriate place and no cards are in the center.
     
     - Returns: True if the user won the game, false otherwise
     */
    func isGameWon() -> Bool {

        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            
            let allowedRanks = getDesignatedRanksByPosition(indexPath: cell.indexPath!)
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
     Game is over if board is full and there are no cards that can be removed or if the next card is royal and it's spots are taken
     
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
}


//MARK: - Hints functions

extension GameVC {
    
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
            
            let placedJacks = getNumberOfCardsPlaced(withRank: .jack)
            let placedQueens = getNumberOfCardsPlaced(withRank: .queen)
            let placedKings = getNumberOfCardsPlaced(withRank: .king)

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
    

    
    
    
    // MARK: - Timer
    
    /**

     */
    func addTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if timer.isValid == true {
            timer.invalidate()
        }
    }
    
    @objc func updateLabel() {
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
    }
    
    @objc func timerElapsed() {
        // If another view controller is presented than pause the timer
        if presentedViewController == nil {
            secondsPassed += 1
            updateLabel()
        }
    }
    
    
    // MARK: - Feedbacks
    
    func haptic(of feedbackType: HapticFeedbackType) {
        
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        
        
        switch feedbackType {
        case .placeError:
            notificationFeedbackGenerator.notificationOccurred(.error)
        case .removeError:
            notificationFeedbackGenerator.notificationOccurred(.error)
        case .placeSuccess:
            notificationFeedbackGenerator.notificationOccurred(.success)
        case .removeSuccess:
            notificationFeedbackGenerator.notificationOccurred(.success)
        case .gameOver:
            notificationFeedbackGenerator.notificationOccurred(.error)
            notificationFeedbackGenerator.notificationOccurred(.error)
        case .win:
            notificationFeedbackGenerator.notificationOccurred(.success)
            notificationFeedbackGenerator.notificationOccurred(.success)
            notificationFeedbackGenerator.notificationOccurred(.success)
        }
    }
    
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
    
    // MARK: - Confetti
    
    func confetti() {
        confettiEmitter.removeFromSuperlayer()
        
        confettiEmitter = CAEmitterLayer()
        confettiEmitter.emitterPosition = CGPoint(x: self.view.frame.size.width / 2, y: -10)
        confettiEmitter.emitterShape = CAEmitterLayerEmitterShape.line
        confettiEmitter.emitterSize = CGSize(width: self.view.frame.size.width, height: 2.0)
        confettiEmitter.emitterCells = generateEmitterCells()

        confettiEmitter.beginTime = CACurrentMediaTime()
        
        self.view.layer.addSublayer(confettiEmitter)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.confettiEmitter.lifetime = 0.0
        }
    }
    
    func generateEmitterCells() -> [CAEmitterCell] {
        
        let confettiImages:[UIImage] = [
            UIImage(named: "confetti-diamond.png")!,
            UIImage(named: "confetti-club.png")!,
            UIImage(named: "confetti-heart.png")!,
            UIImage(named: "confetti-spade.png")!,
            UIImage(named: "confetti-crown.png")!
        ]
        
        let velocities:[Int] = [
            100
            , 500
            , 90
            , 900
            , 200
            , 150
            , 720
        ]
        
        var cells:[CAEmitterCell] = [CAEmitterCell]()
        for index in 0..<confettiImages.count*2 {
            let cell = CAEmitterCell()
            cell.birthRate = 4.0
            cell.lifetime = 14.0
            cell.lifetimeRange = 0
            cell.velocity = CGFloat(velocities[getRandomNumber(velocities.count)])
            cell.velocityRange = 10
            cell.emissionLongitude = CGFloat(Double.pi)
            cell.emissionRange = 0.5
            cell.spin = 3.5
            cell.spinRange = 0
            cell.contents = confettiImages[index % confettiImages.count].cgImage!
            cell.scaleRange = 0.25
            cell.scale = 0.1
            cell.alphaSpeed = -1.0/cell.lifetime
            cells.append(cell)
        }
        return cells
    }
    
    
    private func getRandomNumber(_ limit: Int) -> Int {
        return Int(arc4random_uniform(UInt32(limit)))
    }

}


