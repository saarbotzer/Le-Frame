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
    @IBOutlet weak var next2CardImageView: UIImageView!
    @IBOutlet weak var next3CardImageView: UIImageView!
    
    @IBOutlet weak var doneRemovingAreaStackView: UIStackView!
    @IBOutlet weak var doneRemovingBtn: UIButton!
    @IBOutlet weak var doneRemovingIcon: UIImageView!
    
    @IBOutlet weak var removeAreaStackView: UIStackView!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var removeIcon: UIImageView!
    
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cardsLeftLabel: UILabel!
    @IBOutlet weak var removalSumLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var removalSumTitleLabel: UILabel!
    @IBOutlet weak var removeLabelsView: UIView!
    @IBOutlet weak var removeLabelsBackground: UIView!
    
    
    // Spots available by rank
    var kingsAvailable : Int = 4
    var queensAvailable : Int = 4
    var jacksAvailable : Int = 4
    var spotsAvailable : Int = 16
    
    // Game Data
    var model = CardModel()
    var deck = [Card]()

    var nextCards : [Card] = [Card]()
    var firstSelectedCardIndexPath: IndexPath?
    var secondSelectedCardIndexPath: IndexPath?
    var cardsLeft : Int?
    var moves : [GameMove] = [GameMove]()
    var undosUsed : Int = 0
    
    var difficulty : Difficulty = .default
    
    // Next Cards Spots
    var nextCardPoint : CGPoint?
    var next2CardPoint : CGPoint?
    var next3CardPoint : CGPoint?
    var transformCardsBy: CGFloat?
    
    var gameStatus: GameStatus = .placing
    var allowPlacing: Bool = true
    
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
        Utilities.log(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        // Un-comment to view onboarding screen every time
//        defaults.set(false, forKey: "firstGamePlayed")
        
        setDelegates()
        
        updateUI()
        addRemovalButtonsRecognizer()
        
//        startNewGame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        configureNextCardsUI()
        
        let viewingMode = getViewingMode()
        if viewingMode == .onboarding {
            performSegue(withIdentifier: "goToHowTo", sender: nil)
            defaults.set(true, forKey: "firstGamePlayed")
            
            // TODO: Verify that this is a good place and a way to create uuids
            defaults.set(UUID().uuidString, forKey: "uuid")
        }
        
        startNewGame()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            if let navigationController = segue.destination as? UINavigationController,
                let settingsVC = navigationController.viewControllers.first as? NewSettingsVC {
                settingsVC.gameDifficulty = difficulty
            }
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
        updateRemoveLabelsUI()
    }
    
    func updateRemoveLabelsUI() {
        let radius = removeLabelsBackground.frame.width / 2
        removeLabelsBackground.roundCorners([.allCorners], radius: radius)
        removeLabelsBackground.backgroundColor = .black
        removeLabelsBackground.alpha = 0.5
        
        removalSumLabel.textColor = .white
        removalSumLabel.layer.zPosition = 4
        removalSumTitleLabel.textColor = .white
        removalSumTitleLabel.layer.zPosition = 4//.alpha = 1
    }
    
    func enableRemoveButton(enable: Bool) {
        removeBtn.isEnabled = enable
        removeIcon.alpha = enable ? 1 : 0.5
        removeIcon.isUserInteractionEnabled = enable
        removeAreaStackView.isUserInteractionEnabled = enable
    }
    
    func addRemovalButtonsRecognizer() {
        let removeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removePressed(_:)))
        removeIcon.addGestureRecognizer(removeGestureRecognizer)
        removeAreaStackView.addGestureRecognizer(removeGestureRecognizer)

        let doneRemovingGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneRemovingPressed(_:)))
        doneRemovingIcon.addGestureRecognizer(doneRemovingGestureRecognizer)
        doneRemovingAreaStackView.addGestureRecognizer(doneRemovingGestureRecognizer)

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
    
        

        
        doneRemovingBtn.setTitleColor(UIColor.white, for: .normal)
        doneRemovingBtn.tintColor = .white
        doneRemovingBtn.setTitleColor(disabledColor, for: .disabled)
        doneRemovingIcon.image = doneRemovingIcon.image?.withRenderingMode(.alwaysTemplate)
        doneRemovingIcon.tintColor = .white
        
        removeBtn.tintColor = .white
        removeBtn.setTitleColor(UIColor.white, for: .normal)
        removeBtn.setTitleColor(disabledColor, for: .disabled)
        removeIcon.image = removeIcon.image?.withRenderingMode(.alwaysTemplate)
        removeIcon.tintColor = .white

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
        doneRemovingIcon.isHidden = !show
        removeIcon.isHidden = !show
        removeBtn.isHidden = !show
        enableRemoveButton(enable: false)
        enableDoneRemovingButton(enable: false)
//        removalSumLabel.isHidden = !show
//        removalSumTitleLabel.isHidden = !show
        removeLabelsView.isHidden = !show
        removalSumLabel.adjustsFontSizeToFitWidth = true
        removalSumLabel.minimumScaleFactor = 0.2
        
        hideNextCards(hide: show)
        
        enableOptionCards(forCardAt: nil)
        
//        if show {
//            nextCardImageView.image = UIImage(named: spotImageName)
//        }
    }
    
    /**
     Enables the Done Removing button
     */
    func enableDoneRemovingButton(enable: Bool) {
        
        var shouldEnableBySetting = false
        
//        let doneRemovingAnytime = getSettingValue(for: .doneRemovingAnytime)
        
        if difficulty.doneRemovingAnytime {
            if !isBoardFull() {
                shouldEnableBySetting = true
            }
        } else if !checkForPairs(){
            shouldEnableBySetting = true
        }
        
        let finalDecision = shouldEnableBySetting && enable
        
        doneRemovingBtn.isEnabled = finalDecision
        doneRemovingIcon.alpha = finalDecision ? 1 : 0.5
        doneRemovingIcon.isUserInteractionEnabled = finalDecision
        doneRemovingAreaStackView.isUserInteractionEnabled = finalDecision
    }
    
    // MARK: - Game Flow
    
    
    
    
    
    
    
    // MARK: - IBActions
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 1:
            
//            let settingsVC = NewSettingsVC()
//            settingsVC.gameDifficulty = difficulty
            
            performSegue(withIdentifier: "goToSettings", sender: nil)
        case 2:
            if isGameWon() {
                gameWon(toAddStats: false)
            } else if isGameOver() {
                gameOverFeedback()
            }
            showHints(hintType: .tappedHintButton)
        case 3:
            switch gameStatus {
            case .gameOver:
                showAlert(title: "Try again", message: "Start a new game!", dismissText: "Nevermind", confirmText: "Sure")
            case .won:
                showAlert(title: "Play again", message: "Start a new game!", dismissText: "Nevermind", confirmText: "Sure")
            default:
                showAlert(title: "New Game?", message: "Are you sure you want to start a new game?", dismissText: "Nevermind", confirmText: "Yes")
            }
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
            if difficulty.sumMode == .ten && firstCard.rank! == .ten {
                removeCards(at: [firstSelectedCardIndexPath!])
            } else {
                haptic(of: .removeError)
                Toast.show(message: "Can't remove cards that don't sum to \(difficulty.sumMode.getRawValue())", controller: self)
            }
        // Option 2 - Two cards are selected
        } else if firstSelectedCardIndexPath != nil && secondSelectedCardIndexPath != nil {
            let firstCardCell = getSpot(at: firstSelectedCardIndexPath!)
            let firstCard = firstCardCell.card!
            
            let secondCardCell = getSpot(at: secondSelectedCardIndexPath!)
            let secondCard = secondCardCell.card!
            
            // If the cards match - remove
            if firstCard.rank!.getRawValue() + secondCard.rank!.getRawValue() == difficulty.sumMode.getRawValue() {
                removeCards(at: [firstSelectedCardIndexPath!, secondSelectedCardIndexPath!])
            } else {
                haptic(of: .removeError)
                Toast.show(message: "Can't remove cards that don't sum to \(difficulty.sumMode.getRawValue())", controller: self)
            }
        }
                
        resetCardIndexes()
        
        markCardAsSelected(at: nil)
        enableOptionCards(forCardAt: nil)
        
        finishedRemovingCard()
    }
    
    func removeCards(at indexPaths: [IndexPath]) {
        var newlyRemovedCards = [Card]()
        var cardsLocations = [IndexPath]()
        
        for indexPath in indexPaths {
            let cell = getSpot(at: indexPath)
            let card = cell.card!
            playSound(.removeCard)
            haptic(of: .removeSuccess)
            newlyRemovedCards.append(card)
            cardsLocations.append(indexPath)
            cell.removeCard()
        }
        
        enableRemoveButton(enable: false)
        enableDoneRemovingButton(enable: true)
        
        let move = GameMove(cards: newlyRemovedCards, indexPaths: cardsLocations, moveType: .remove)
        moves.append(move)
    }
    
    
    /** Called when **Done** button is pressed.
     Switches between removing and placing game modes and deselects all cards.
     */
    @IBAction func doneRemovingPressed(_ sender: Any) {
        finishedPlacingCard(cardPlaced: false)
        
        markCardAsSelected(at: nil)
        enableOptionSpots()
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
    
    // didSelectCard
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        switch gameStatus {
        case .placing:
            if allowPlacing {
                let cardPlaced = placeCard(at: indexPath)
                finishedPlacingCard(cardPlaced: cardPlaced)
            }
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
//        let gridWidth = collectionView.frame.width
//        let spacing: CGFloat = (gridWidth - (4 * cardWidth)) / 4
//        let totalSpacingWidth: CGFloat = spacing * (4 - 1)
        
        let edgeInsets = (self.view.frame.size.width - (4 * cardWidth)) / (4 + 1)
        
        return UIEdgeInsets(top: 5.0, left: edgeInsets, bottom: 5.0, right: edgeInsets)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        let gridWidth = collectionView.frame.width
//        let spacing = (gridWidth - (4 * cardWidth)) / 4
        
        cardHeight = collectionView.frame.height / 4 - 10
        cardWidth = cardHeight / 3 * 2
        

        return CGSize(width: cardWidth, height: cardHeight)
    }
    
    // MARK: - Spots Handling and Interface Methods

    func animateCard(card: Card, from origin: IndexPath, to destination: IndexPath) {
        animateCard(card: card, from: origin as Any, to: destination as Any)
    }
    
    func animateCard(card: Card, from origin: IndexPath, to destination: CardAnimationLocation) {
        animateCard(card: card, from: origin as Any, to: destination as Any)
    }
    
    func animateCard(card: Card, from origin: CardAnimationLocation, to destination: IndexPath) {
        animateCard(card: card, from: origin as Any, to: destination as Any)
    }
    
    func animateCard(card: Card, from origin: CardAnimationLocation, to destination: CardAnimationLocation) {
        animateCard(card: card, from: origin as Any, to: destination as Any)
    }
    
    func animateCard(card: Card, from origin: Any, to destination: Any) {

        allowPlacing = false
        
        let originFrame = getFrame(for: origin)
        let destinationFrame = getFrame(for: destination)
        
        // Create moving imageView
        let tempImageView = UIImageView(image: UIImage(named: card.imageName))

        // Apply origin properties to imageView
        tempImageView.frame = originFrame        
        
        var destinationTransform = CGAffineTransform.identity

        
        
        if let originAsLocation = origin as? CardAnimationLocation {
            tempImageView.transform = CGAffineTransform.identity.rotated(by: getRotationForLocation(location: originAsLocation))
        }
        
        if let destinationAsLocation = destination as? CardAnimationLocation {
            destinationTransform = CGAffineTransform.identity.rotated(by: getRotationForLocation(location: destinationAsLocation))
        } else {
            tempImageView.layer.zPosition = 10
        }
        
        tempImageView.addShadow(with: 1)
        
        // TODO: Understand whether transform or frame first, find a better solution
        var frameFirst = false
        if let originAsLocation = origin as? CardAnimationLocation, let destinationAsLocation = destination as? CardAnimationLocation {
            frameFirst = ((originAsLocation == .next2Card) && (destinationAsLocation == .nextCard))
        }
        
        frameFirst = true
       
        // Add the imageView to the main view
        view.addSubview(tempImageView)

        // Animate
        UIView.animate(withDuration: cardAnimationDuration) {
            if frameFirst {
                tempImageView.frame     = destinationFrame
                tempImageView.bounds    = destinationFrame

                tempImageView.transform = destinationTransform

            } else {
                tempImageView.transform = destinationTransform
                tempImageView.frame     = destinationFrame
            }
        }
       
        // Remove imageView after when arriving to destination
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
            tempImageView.removeFromSuperview()
            self.allowPlacing = true
        }
    }
    
    func getRotationForLocation(location: CardAnimationLocation) -> CGFloat {
        
        switch difficulty.numberOfNextCards {
        case 3:
            switch location {
            case .nextCard:
                return 0.2
            case .next3Card:
                return -0.2
            default:
                return 0
            }
        case 2:
            switch location {
            case .nextCard:
                return 0.2
            case .next2Card:
                return -0.2
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
        
    func getFrame(for location: Any) -> CGRect {

        var point : CGPoint = CGPoint()
        var size : CGSize = CGSize()
        
        
        if let indexPath = location as? IndexPath {
            let cell = getSpot(at: indexPath)
            
            point = cell.superview?.convert(cell.frame.origin, to: nil) ?? point
            size = cell.frame.size
        } else if let location = location as? CardAnimationLocation {
            switch location {
            case .nextCard:
                point = nextCardPoint ?? point
                size = nextCardImageView.bounds.size
            case .next2Card:
                point = next2CardPoint ?? point
                size = next2CardImageView.bounds.size
            case .next3Card:
                point = next3CardPoint ?? point
                size = next3CardImageView.bounds.size
            case .removedStack:
                point = CGPoint(x: self.view.frame.midX, y: self.view.frame.maxY + cardHeight + 10)
                size = CGSize(width: cardWidth, height: cardHeight)
            default:
                return CGRect(origin: point, size: size)
            }
        }
        
        let rect = CGRect(origin: point, size: size)
        return rect
        
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
        
        if let nextCardRank = nextCards[0].rank {
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
    
    func finishedPlacingCard(cardPlaced: Bool) {
        
        checkAvailability()
        
        
        let boardFull = isBoardFull()
        let cardsToRemove = checkForPairs()
        let nextCardIsBlocked = isNextCardBlocked()
        
        updateCardsLeftLabel()
        
        if boardFull {
            if cardsToRemove {
                print("a")
                setGameStatus(status: .removing)
            } else {
                print("b")
                setGameStatus(status: .gameOver)
            }
        } else if nextCardIsBlocked {
            print("c")
            setGameStatus(status: .gameOver)
        } else if gameStatus == .removing {
            print("d")
            setGameStatus(status: .placing)
        } else if cardsLeft == 0 {
            print("e")
            setGameStatus(status: .removing)
        }
        
        if isGameWon() {
            print("f")
            setGameStatus(status: .won)
        }
        
        if cardPlaced {
            animateNextCards()
        }
    }
    
    /**
     Handles what happens after pressed remove.
     The function checks if it is the case of a full frame with middle cards that can't be removed (whilst no more cards in the deck) and if so it sets the game as over.
     */
    func finishedRemovingCard() {
        
        let cardsToRemove = getCardsToRemove()

        if cardsToRemove.count == 0 {
            Toast.show(message: "No more cards to remove. Tap done", controller: self)
        }
        
        let cardsAtCenter = getEmptySpots(atCenter: true)
        
        if let cardsLeft = cardsLeft {
            if cardsLeft == 0 && cardsToRemove.count == 0 && cardsAtCenter.count != 4 {
                setGameStatus(status: .gameOver)
                nextCardImageView.image = UIImage(named: spotImageName)
            } else {
            }
        }
    }

    func removeAllCards() {
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            cell.removeCard()
        }
    }
    
    func markCardAsSelected(at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            if let cell = spotsCollectionView.cellForItem(at: indexPath) as? CardCollectionViewCell {
                cell.mark(as: .selected, on: true)
            }
        } else {
            for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
                cell.mark(as: .selected, on: false)
            }
        }
    }
    
    func enableOptionSpots() {
        let settingIsOn = getSettingValue(for: .highlightAvailableMoves)
        
        let allSpots = Utilities.getSpots(forRank: .ace, overlapping: true)
        var spotsToEnable: [IndexPath] = allSpots
        var spotsToDisable: [IndexPath] = []

        // Option 1 - Disable nothing
        if !settingIsOn || nextCards.count < 1 {
            spotsToEnable = allSpots
        // Option 2 - Disable not royal-specific spots
        } else if let nextCardRank = nextCards[0].rank {
            spotsToEnable = []
            let allSpotsForRank = Utilities.getSpots(forRank: nextCardRank, overlapping: true)
            for spotIndexPath in allSpotsForRank {
                let optionSpot = getSpot(at: spotIndexPath)
                if optionSpot.isEmpty {
                    spotsToEnable.append(spotIndexPath)
                }
            }
            
            let placedSpots = getPlacedIndexPaths(placed: true)
            spotsToEnable.append(contentsOf: placedSpots)
        }
            
        spotsToDisable = allSpots.difference(from: spotsToEnable)
        
        for ip in spotsToEnable {
            let spot = getSpot(at: ip)
            spot.mark(as: .disabledForPlacing, on: false)
        }
        
        for ip in spotsToDisable {
            let spot = getSpot(at: ip)
            spot.mark(as: .disabledForPlacing, on: true)
        }
    }
    
    
    func enableOptionCards(forCardAt indexPath: IndexPath?, enableAll: Bool = false) {
        
        let settingIsOn = getSettingValue(for: .highlightAvailableMoves)
        let selectedCards = getSelectedIndexPaths(selected: true)
        
        let allSpots = Utilities.getSpots(forRank: .ace, overlapping: true)
        var cardsToEnable: [IndexPath] = []
        var cardsToDisable: [IndexPath] = []
        
        // Option 1 - Disable nothing | When the setting is off
        let enableAllCards = enableAll || !settingIsOn
        if enableAllCards {
            cardsToEnable = allSpots
        }
        
        // Option 2 - Disable all cards that can't be paired with another card | When setting is on & no indexPath & no cards are selected
        if settingIsOn && !enableAll && indexPath == nil && selectedCards.count == 0 {
            cardsToEnable = getCardsToRemove(false)
            
        }
        
        // Option 3 - Disable all cards that are not selected | When setting is on & no indexPath & 2 cards are selected
        if settingIsOn && indexPath == nil && selectedCards.count == 2 {
            cardsToEnable = selectedCards
        }
        
        // Option 4 - Disable all cards that can't be removed with the card at indexPath | When setting is on and there is an indexPath
        if settingIsOn && indexPath != nil {
            cardsToEnable = getCardsToPairWith(cardAt: indexPath!)
            cardsToEnable.append(indexPath!)
        }
        
        cardsToDisable = allSpots.difference(from: cardsToEnable)

        for ip in cardsToEnable {
            let spot = getSpot(at: ip)
            spot.mark(as: .disabledForRemoving, on: false)
        }
        
        for ip in cardsToDisable {
            let spot = getSpot(at: ip)
            spot.mark(as: .disabledForRemoving, on: true)
        }
    }
    
    
    func getCardsToPairWith(cardAt indexPath: IndexPath) -> [IndexPath] {
        let selectedSpot = getSpot(at: indexPath)
        let selectedCard = selectedSpot.card!
        var optionsIndexPaths: [IndexPath] = []
        
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            if let card = cell.card {
                if selectedCard.rank!.getRawValue() + card.rank!.getRawValue() == difficulty.sumMode.getRawValue() {
                    let indexPathToAdd = cell.indexPath!
                    if indexPathToAdd != indexPath {
                        optionsIndexPaths.append(cell.indexPath!)
                    }
                }
            }
        }
        
        return optionsIndexPaths
    }
    
    
    func getSelectedIndexPaths(selected: Bool) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for spot in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            if spot.isSpotSelected == selected {
                indexPaths.append(spot.indexPath!)
            }
        }
        return indexPaths
    }
    
    func getPlacedIndexPaths(placed: Bool) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for spot in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            if spot.isEmpty != placed {
                indexPaths.append(spot.indexPath!)
            }
        }
        return indexPaths
    }
    

//    func markOptionCards(forCardAt indexPath: IndexPath? = nil, shouldMark: Bool = true) {
//        var shouldMark: Bool = shouldMark
//        var optionsIndexPaths = [IndexPath]()
//        var markType: CardMarkEvent = .disabledForRemoving
//
//        if let indexPath = indexPath {
//            markType = .disabledForRemoving
//
//            let selectedCell = spotsCollectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
//            let selectedCard = selectedCell.card!
//
//
//            // Finding spots to "disable" for a specific selected card
//            for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
//                if let card = cell.card {
//                    if selectedCard.rank!.getRawValue() + card.rank!.getRawValue() != difficulty.sumMode.getRawValue() {
//                        let indexPathToAdd = cell.indexPath!
//                        if indexPathToAdd != indexPath {
//                            optionsIndexPaths.append(cell.indexPath!)
//                        }
//                    }
//                }
//            }
//
//            // TODO: Make it to be only in case that the setting is on
//            shouldMark = true
//        } else {
//            if gameStatus == .placing {
//                markType = .disabledForPlacing
//
//                if nextCards.count < 1 {
//                    return
//                }
//
//                if let nextCardRank = nextCards[0].rank {
//                    let allSpotsForRank = Utilities.getSpots(forRank: nextCardRank, overlapping: true)
//
//                    for spotIndexPath in allSpotsForRank {
//                        let optionCell = spotsCollectionView.cellForItem(at: spotIndexPath) as! CardCollectionViewCell
//                        if !optionCell.isEmpty {
//                            optionsIndexPaths.append(spotIndexPath)
//                        }
//                    }
//
//                } else {
//                    return
//                }
//            } else {
//                markType = .disabledForRemoving
//                shouldMark = false
//            }
//        }
//
//        if shouldMark && getSettingValue(for: .markSpots) {
//            for optionIndexPath in optionsIndexPaths {
//                let optionCell = spotsCollectionView.cellForItem(at: optionIndexPath) as! CardCollectionViewCell
//                optionCell.mark(as: markType, on: true)
//            }
//        } else {
//
//            // Marking all cells as enables
//            for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
//                cell.mark(as: markType, on: false)
//            }
//        }
//    }

    // MARK: - Game Logic Functions

    // Game Logic
    
    
    /**
     Checks if the card can be put at the spot and does it if so.
     - Parameter indexPath: The spot's IndexPath
     
     - Returns: True if the card was placed, false otherwise
     */
    func placeCard(at indexPath: IndexPath) -> Bool {
        
        if nextCards.count < 1 {
            return false
        }
        
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
        
        if canPutCard(nextCards[0], at: indexPath) {
            // Put the card in the spot and go to the next card
            playSound(.placeCard)

            animateCard(card: nextCards[0], from: .nextCard, to: indexPath)
            blockedCardTaps = 0
            cell.setCard(nextCards[0])
            let move = GameMove(cards: [nextCards[0]], indexPaths: [indexPath], moveType: .place)
            moves.append(move)
            haptic(of: .placeSuccess)
            
            requestNextCard(firstCard: false)
//            cardsLeft = cardsLeft! - 1
            return true
        } else {
            
            let spot = getSpot(at: indexPath)
            var toastString = ""

            if spot.isEmpty {
                if let nextCardRank = nextCards[0].rank {
                    switch nextCardRank {
                    case .jack:
                        toastString = "Jacks can only be placed at the middle-left and middle-right"
                    case .queen:
                        toastString = "Queens can only be placed at the middle-top and middle-bottom"
                    case .king:
                        toastString = "Kings can only be placed at the corners"
                    default:
                        toastString = ""
                    }
                }
            } else {
                toastString = "Can't place card in an occupied spot"
            }
            
            Toast.show(message: toastString, controller: self)
            
            haptic(of: .placeError)

            blockedCardTaps += 1
            
            if blockedCardTaps > 2 {
                self.showHints(hintType: .tappedTooManyTimes)
            }
        }
        
        return false
    }
    
    
    /**
     Checks what card are already selected and selects/deselects accordingly.
     
     - Parameter indexPath: The tapped spot's IndexPath
     */
    func selectCardForRemoval(at indexPath: IndexPath) {
        
        //TODO: Improve syntax, too many repeating lines
        
        
        let tappedSpot = getSpot(at: indexPath)
        
        // In case of pressing an empty spot in removal mode
        if tappedSpot.isEmpty  || [CardRank.jack, CardRank.queen, CardRank.king].contains(tappedSpot.card?.rank){
            return
        }
        
        enableRemoveButton(enable: true)
        
        let rank = tappedSpot.card!.rank!
        
        // If this is the first selected card, select the tapped card
        if firstSelectedCardIndexPath == nil {
            firstSelectedCardIndexPath = indexPath
            secondSelectedCardIndexPath = nil
            
            markCardAsSelected(at: firstSelectedCardIndexPath)
            enableOptionCards(forCardAt: firstSelectedCardIndexPath)
            
        } else {
            // If the tapped card is already selected, deselect it
            if firstSelectedCardIndexPath == indexPath {
                
                // TODO: Add removal when 10 pressed twice
                if difficulty.sumMode == .ten && rank == .ten {
                    removeCards(at: [firstSelectedCardIndexPath!])
                }
                
                firstSelectedCardIndexPath = nil
                secondSelectedCardIndexPath = nil
                
                markCardAsSelected(at: nil)
                enableOptionCards(forCardAt: nil)
                
                enableRemoveButton(enable: false)
            }
            // If no second card is selected, select the tapped card
            else if secondSelectedCardIndexPath == nil {
                secondSelectedCardIndexPath = indexPath
                
                markCardAsSelected(at: secondSelectedCardIndexPath)
                enableOptionCards(forCardAt: nil)
            }
            // If two cards are already selected, deselect them and select the tapped card
            else {
                markCardAsSelected(at: nil)
                
                firstSelectedCardIndexPath = indexPath
                secondSelectedCardIndexPath = nil
                
                markCardAsSelected(at: firstSelectedCardIndexPath)
                enableOptionCards(forCardAt: firstSelectedCardIndexPath)
            }
        }
    }
    
    func updateCardsLeftLabel() {
        cardsLeftLabel.text = "CARDS LEFT: \(cardsLeft ?? 0)"
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
        if allNonRoyalValues.contains(10) && difficulty.sumMode == .ten{
            return true
        }
        for i in 0..<allNonRoyalValues.count {
            for j in i+1..<allNonRoyalValues.count {
                if allNonRoyalValues[i] + allNonRoyalValues[j] == difficulty.sumMode.getRawValue() {
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
        didWin = false
        gameOverFeedback()
        
        if let cardsLeft = cardsLeft {
            if cardsLeft > 0 {
                showNextCards()
            }
        }
        enableOptionCards(forCardAt: nil, enableAll: true)

        if toAddStats {
            addStats()
        }
    }
    
    func gameOverFeedback() {
        gameLoseReason = getLoseReason()
        let loseReasonText = getLoseReasonText(loseReason: gameLoseReason)
        let statsText = getGameStatsText()
        let messageText = "\(loseReasonText)\n\n\(statsText)"

        playSound(.lose)
        haptic(of: .gameOver)
        showAlert(title: "Game Over", message: messageText, dismissText: "OK", confirmText: "Start a new game")

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
            return "There aren't any cards that sum up to \(difficulty.sumMode) to remove."
        default:
            return ""
        }
    }
    
    func getLoseReason() -> LoseReason {
        if !checkForPairs() && isBoardFull() {
            return .noCardsToRemove
        }
        
        if nextCards.count < 1 {
            return .noCardsToRemove
        }
        
        if let nextCardRank = nextCards[0].rank {
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
        
        playSound(.win)
        confetti()
        haptic(of: .win)
        didWin = true
        
        let statsText = getGameStatsText()
        
        var messageText = ""
        var title = ""
        
        if let fastestWinDuration = getFastestWinDuration() {
            if secondsPassed < fastestWinDuration {
                // This win is the fastest
                title = "Fastest Win!"
                messageText = "This is your fastest win yet! Amazing! \(statsText)"
            } else {
                // A regular win
                title = "You Won!"
                messageText = "Good job! You filled the frame with royal cards\n\n\(statsText)"
            }
        } else {
            // This is the first win
            title = "First Win!"
            messageText = "Excellent! This is your first win! \(statsText)"
        }
        
                
        showAlert(title: title, message: messageText, dismissText: "Great", confirmText: "Start a new game")
        
        nextCardImageView.image = UIImage(named: spotImageName)
        enableOptionCards(forCardAt: nil, enableAll: true)
        
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
            gameStatsToAdd.loseReason = didWin ? gameLoseReason.getRawValue() : ""
            gameStatsToAdd.nofCardsLeft = Int16(cardsLeft!)
            gameStatsToAdd.nofJacksPlaced = Int16(getNumberOfCardsPlaced(withRank: .jack))
            gameStatsToAdd.nofKingsPlaced = Int16(getNumberOfCardsPlaced(withRank: .king))
            gameStatsToAdd.nofQueensPlaced = Int16(getNumberOfCardsPlaced(withRank: .queen))
            gameStatsToAdd.nofHintsUsed = Int16(hintsUsed)
            gameStatsToAdd.restartAfter = restartAfter
            gameStatsToAdd.startTime = startTime
            gameStatsToAdd.sumMode = Int16(difficulty.sumMode.getRawValue())
            gameStatsToAdd.difficulty = difficulty.name
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
            Utilities.log("Error saving context: \(error)")
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
            }
        }
        catch {
            Utilities.log(error)
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
                "deck": game.deck as Any,
                "didWin": game.didWin,
                "duration": game.duration,
                "loseReason": game.loseReason as Any,
                "numberOfCardsLeft": game.nofCardsLeft,
                "numberOfJacksPlaced": game.nofJacksPlaced,
                "numberOfKingsPlaced": game.nofKingsPlaced,
                "numberOfQueensPlaced": game.nofQueensPlaced,
                "numberOfHintsUsed": game.nofHintsUsed,
                "didRestartAfter": game.restartAfter,
                "startTime": game.startTime as Any,
                "sumMode": game.sumMode,
                "difficulty": game.difficulty as Any,
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
        let ref = Firestore.firestore().document(referenceString)
        
        ref.setData(dataToAdd) { (err) in
            if let err = err {
                Utilities.log("Error adding document: \(err)")
                statsUploaded = false
            } else {
                statsUploaded = true
            }
        }
        return statsUploaded
    }
    
    func getFastestWinDuration() -> Int? {
        var fastestWin: Int?
        let request : NSFetchRequest<Game> = Game.fetchRequest()
        request.predicate = NSPredicate(format: "gameID != %@", gameID.uuidString)
        do {
            let results = try context.fetch(request)
            for res in results {
                let gameDuration = Int(res.duration)
                if res.didWin {
                    if fastestWin != nil {
                        fastestWin = gameDuration < fastestWin! ? gameDuration : fastestWin!
                    } else {
                        fastestWin = gameDuration
                    }
                }
            }
        } catch {
            Utilities.log("Error fetching data from context: \(error)")
        }
        return fastestWin
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


        difficulty = getDifficulty()
        
        
        // Stats
        restartAfter = false
        gameFinished = false
        gameID = UUID()
        startTime = Date()
        statsAdded = false
        secondsPassed = 0
        hintsUsed = 0
        undosUsed = 0
        
        moves = []
        
        
        // Get deck
        deck = model.getDeck(ofType: .regularDeck, random: true, from: nil, fullDeck: nil)
//        deck = model.getDeck(ofType: .onlyRoyals, random: false, from: nil, fullDeck: nil)
//        deck = model.getDeck(ofType: .notRoyals, random: false, from: nil, fullDeck: nil)
//        deck = model.getDeck(ofType: .fromString, random: false, from: "h10d05c10c05h13c13d13s13h12c12d12s12h11c11d11s11", fullDeck: false)
        
        deckString = model.getDeckString(deck: deck)
        
        cardsLeft = deck.count
        
        Utilities.log("Started new game \(gameID.uuidString)")
        
        stopTimer()

        // UI
        configureNextCardsUI()
        removalSumLabel.text = "\(difficulty.sumMode.getRawValue())"
        updateCardsLeftLabel()
        
        markCardAsSelected(at: nil)
        enableOptionSpots()
        
        removeAllCards()
        confettiEmitter.removeFromSuperlayer()

        
        // Handle first card
        requestNextCard(firstCard: true)
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

        let canWinWithCardsInTheMiddle = true
        
        for cell in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            
            let allowedRanks = getDesignatedRanksByPosition(indexPath: cell.indexPath!)
            // If the spot contains a card that does not match it's designated rank, the function returns false.
            if let card = cell.card {
                let cardRank = card.rank!
                if (allowedRanks == .jacks && cardRank != .jack) || (allowedRanks == .queens && cardRank != .queen) || (allowedRanks == .kings && cardRank != .king) || (allowedRanks == .notRoyal && !canWinWithCardsInTheMiddle) {
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
        let nextCardRank = nextCards[0].rank!
        
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
    
    func undo() {
        if !difficulty.undosAvailable {
            return
        }
        
        if let lastMove = moves.popLast() {
            switch lastMove.moveType {
            case .remove:
                if gameStatus != .removing {
                    moves.append(lastMove)
                    return
                }
                
                for (card, indexPath) in zip(lastMove.cards, lastMove.indexPaths) {
                    
                    let cell = getSpot(at: indexPath)
                    
                    animateCard(card: card, from: .removedStack, to: indexPath)
                    
                    cell.setCard(card)
                }
                undosUsed += 1
            case .place:
                if gameStatus != .placing {
                    moves.append(lastMove)
                    return
                }
                for (card, indexPath) in zip(lastMove.cards, lastMove.indexPaths) {
                    let cell = getSpot(at: indexPath)
                    
                    animateCard(card: card, from: indexPath, to: .nextCard)
                    
                    cell.removeCard()
                    deck.insert(nextCards[0], at: 0)
                    nextCards[0] = card
                    cardsLeft! += 1
                    updateCardsLeftLabel()
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
                        self.nextCardImageView.image = UIImage(named: card.imageName)
                    }
                }
                undosUsed += 1
            }
        }
        
    }
}


//MARK: - Hints functions

extension GameVC {
    
    func showHints(hintType : HintType) {
        let isShowHints = getSettingValue(for: .showHints)
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
        
        spot.mark(as: .hint, on: true)
    }
    
    func getHints() -> [IndexPath] {
        var indexPathsToHint = [IndexPath]()
        
        if gameStatus == .placing {
            if let nextCardRank = nextCards[0].rank {
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
    
    func getCardsToRemove(_ randomElement: Bool = true) -> [IndexPath] {
        var cardsSpots = [IndexPath]()
        
        var allPairs = [[IndexPath]]()
        
        for spot1 in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
            if let card1 = spot1.card {
                let card1RankValue = card1.rank!.getRawValue()
                if card1RankValue < 11 {
                    if card1RankValue == difficulty.sumMode.getRawValue() {
                        if randomElement {
                            return [spot1.indexPath!]
                        } else {
                            allPairs.append([spot1.indexPath!])
                        }
                    }
                    for spot2 in spotsCollectionView.visibleCells as! [CardCollectionViewCell] {
                        if let card2 = spot2.card {
                            let card2RankValue = card2.rank!.getRawValue()
                            if card2RankValue < 11 && spot1 != spot2 {
                                if card1RankValue + card2RankValue == difficulty.sumMode.getRawValue() {
                                    allPairs.append([spot1.indexPath!, spot2.indexPath!])
                                }
                            }
                        }
                    }
                }
            }
        }
        if randomElement {
            if let randomPair = allPairs.randomElement() {
                cardsSpots = randomPair
            }
        } else {
            cardsSpots = allPairs.flatMap { $0 }
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
        
        let hapticOn = getSettingValue(for: .hapticOn)
        if !hapticOn {
            return
        }
        
        let hapticGenerator = UINotificationFeedbackGenerator()
        hapticGenerator.prepare()
        
        
        switch feedbackType {
        case .placeError:
            hapticGenerator.notificationOccurred(.error)
        case .removeError:
            hapticGenerator.notificationOccurred(.error)
        case .placeSuccess:
            hapticGenerator.notificationOccurred(.success)
        case .removeSuccess:
            hapticGenerator.notificationOccurred(.success)
        case .gameOver:
            hapticGenerator.notificationOccurred(.error)
            hapticGenerator.notificationOccurred(.error)
        case .win:
            hapticGenerator.notificationOccurred(.success)
            hapticGenerator.notificationOccurred(.success)
            hapticGenerator.notificationOccurred(.success)
        }
    }
    
    func playSound(_ sound: Sound) {
             
        let soundFileFullName = sound.getRawValue()
        
        let soundsOn = getSettingValue(for: .soundsOn)
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
            Utilities.log(error.localizedDescription)
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


// MARK: - Settings and Defaults
extension GameVC {
    
    func isSettingExists(settingKey: SettingKey) -> Bool {
        let currentlySavedKeys = defaults.dictionaryRepresentation().keys
        return currentlySavedKeys.contains(settingKey.getRawValue())
    }
    
    func getViewingMode() -> OnboardingViewingMode {
        let firstGame = !defaults.bool(forKey: "firstGamePlayed")
        
        if firstGame {
            return .onboarding
        } else {
            return .howTo
        }
    }
    
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
    
    func getDifficulty() -> Difficulty {
        let settingKey = SettingKey.difficulty
        let keyExists = isSettingExists(settingKey: settingKey)
        
        let defaultValue = Difficulty.default.name
        
        var difficultyString = defaultValue
        
        if keyExists {
            difficultyString = defaults.string(forKey: settingKey.getRawValue())!
        } else {
            defaults.set(defaultValue, forKey: settingKey.getRawValue())
        }
        
        switch difficultyString {
        case "veryEasy":
            return .veryEasy
        case "easy":
            return .easy
        case "normal":
            return .normal
        case "hard":
            return .hard
        default:
            return .normal
        }
    }
    
    func getSettingValue(for settingKey: SettingKey) -> Bool {
        let keyExists = isSettingExists(settingKey: settingKey)
        if keyExists {
            return defaults.bool(forKey: settingKey.getRawValue())
        } else {
            return setDefaultSetting(for: settingKey)
        }
    }
    
    func setDefaultSetting(for settingKey: SettingKey) -> Bool {
        var defaultValue = true
        switch settingKey {
        case .hapticOn, .soundsOn, .showHints, .highlightAvailableMoves:
            defaultValue = true
        case .doneRemovingAnytime:
            defaultValue = false
        default:
            defaultValue = false
        }
        
        defaults.set(defaultValue, forKey: settingKey.getRawValue())
        return defaultValue
    }
    
}


struct GameMove: CustomStringConvertible {
    var cards: [Card]
    var indexPaths: [IndexPath]
    var moveType: MoveType
    
    public var description: String {
        var locationStr = ""
        var actionStr = ""
        var cardsStrings: [String] = [String]()
        
        if self.moveType == .place {
            actionStr = "Placed"
            locationStr = "at"
        } else if self.moveType == .remove {
            actionStr = "Removed"
            locationStr = "from"
        }
        for (card, indexPath) in zip(cards, indexPaths) {
            cardsStrings.append("\(card) \(locationStr) \(indexPath)")
        }
        
        return "\(actionStr) \(cardsStrings.joined(separator: ", "))"
    }
}


//MARK: - Levels
extension GameVC {
    func configureNextCardsUI() {
        
        switch difficulty.numberOfNextCards {
        case 3:
            // Hidden?
            nextCardImageView.isHidden = false
            next2CardImageView.isHidden = false
            next3CardImageView.isHidden = false
            
            // Location
            nextCardImageView.transform = CGAffineTransform(translationX: 30, y: 0)
            next2CardImageView.transform = CGAffineTransform.identity
            next3CardImageView.transform = CGAffineTransform(translationX: -30, y: 0)
            
        case 2:
            nextCardImageView.isHidden = false
            next2CardImageView.isHidden = false
            next3CardImageView.isHidden = true

            // Location
            nextCardImageView.transform = CGAffineTransform(translationX: 15, y: 0)
            next2CardImageView.transform = CGAffineTransform(translationX: -15, y: 0)

        default:
            nextCardImageView.isHidden = false
            next2CardImageView.isHidden = true
            next3CardImageView.isHidden = true
            
            nextCardImageView.transform = CGAffineTransform.identity
        }
        

        // Set center points
        let point = CGPoint()
        
        nextCardPoint = nextCardImageView.superview?.convert(nextCardImageView.frame.origin, to: nil) ?? point
        next2CardPoint = next2CardImageView.superview?.convert(next2CardImageView.frame.origin, to: nil) ?? point
        next3CardPoint = next3CardImageView.superview?.convert(next3CardImageView.frame.origin, to: nil) ?? point
        
        // Rotation
        nextCardImageView.transform = nextCardImageView.transform.rotated(by: getRotationForLocation(location: .nextCard))
        next2CardImageView.transform = next2CardImageView.transform.rotated(by: getRotationForLocation(location: .next2Card))
        next3CardImageView.transform = next3CardImageView.transform.rotated(by: getRotationForLocation(location: .next3Card))

        // Add Shadows
        nextCardImageView.addShadow(with: 1)
        next2CardImageView.addShadow(with: 1)
        next3CardImageView.addShadow(with: 1)
    }
    
    
    
    func animateNextCards(cards: [Card]) {
                
        if gameStatus == .removing {
            return
        }
        
        nextCardImageView.isHidden = difficulty.numberOfNextCards > 1

        var cardsImages : [String] = []
        for card in cards {
            cardsImages.append(card.imageName)
        }
        
        while cardsImages.count < 3 {
            cardsImages.append(spotImageName)
        }
        
        next3CardImageView.image = UIImage(named: cardsImages[2])

        if cards.count > 1 && difficulty.numberOfNextCards == 3 {
            animateCard(card: cards[1], from: .next3Card, to: .next2Card)
        }
        
        next2CardImageView.image = UIImage(named: cardsImages[1])
        
        if cards.count > 0 && difficulty.numberOfNextCards >= 2 {
            animateCard(card: cards[0], from: .next2Card, to: .nextCard)
        }
        
        nextCardImageView.image = UIImage(named: cardsImages[0])
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
            self.nextCardImageView.isHidden = false
        }
        
    }
    
    
    func showNextCards() {
        
        var cardsImages : [String] = []
        for card in nextCards {
            cardsImages.append("\(card.imageName)")
        }
        
        while cardsImages.count < 3 {
            cardsImages.append(spotImageName)
        }

        nextCardImageView.image = UIImage(named: cardsImages[0])
        next2CardImageView.image = UIImage(named: cardsImages[1])
        next3CardImageView.image = UIImage(named: cardsImages[2])

        switch difficulty.numberOfNextCards {
        case 3:
            nextCardImageView.isHidden = false
            next2CardImageView.isHidden = false
            next3CardImageView.isHidden = false
        case 2:
            nextCardImageView.isHidden = false
            next2CardImageView.isHidden = false
            next3CardImageView.isHidden = true

        default:
            nextCardImageView.isHidden = false
            next2CardImageView.isHidden = true
            next3CardImageView.isHidden = true
        }
        
        
    }
    
    func hideNextCards(hide: Bool) {
        let placeholderCard = Card()
        placeholderCard.imageName = spotImageName
        
        var nextCardsToAnimate = nextCards
        while nextCardsToAnimate.count < 3 {
            nextCardsToAnimate.append(placeholderCard)
        }
        
        var exitFunc = !difficulty.hideNextCardsWhenRemoving
        
        if let cardsLeft = cardsLeft {
            exitFunc = exitFunc || cardsLeft == 0
        }
        
        if exitFunc {
            showNextCards()
            return
        }
        
        if hide {
            switch difficulty.numberOfNextCards {
            case 3:
                nextCardImageView.isHidden = true
                next2CardImageView.isHidden = true
                next3CardImageView.isHidden = true
                
//                animateCard(card: nextCardsToAnimate[0], from: .nextCard, to: .removedStack)
                animateCard(card: nextCardsToAnimate[1], from: .next2Card, to: .removedStack)
                animateCard(card: nextCardsToAnimate[2], from: .next3Card, to: .removedStack)
            case 2:
                nextCardImageView.isHidden = true
                next2CardImageView.isHidden = true

//                animateCard(card: nextCardsToAnimate[0], from: .nextCard, to: .removedStack)
                animateCard(card: nextCardsToAnimate[1], from: .next2Card, to: .removedStack)
            default:
//                animateCard(card: nextCardsToAnimate[0], from: .nextCard, to: .removedStack)
                
                nextCardImageView.isHidden = true
            }
        } else {
            if !nextCardImageView.isHidden { return }
                        
            var cardsImages : [String] = []
            for card in nextCards {
                cardsImages.append(card.imageName)
            }
            
            while cardsImages.count < 3 {
                cardsImages.append(spotImageName)
            }
            
            nextCardImageView.image = UIImage(named: cardsImages[0])
            next2CardImageView.image = UIImage(named: cardsImages[1])
            next3CardImageView.image = UIImage(named: cardsImages[2])

            switch difficulty.numberOfNextCards {
            case 3:
                animateCard(card: nextCardsToAnimate[2], from: .removedStack, to: .next3Card)
                animateCard(card: nextCardsToAnimate[1], from: .removedStack, to: .next2Card)
                animateCard(card: nextCardsToAnimate[0], from: .removedStack, to: .nextCard)

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
                    self.nextCardImageView.isHidden = false
                    self.next2CardImageView.isHidden = false
                    self.next3CardImageView.isHidden = false
                }
            case 2:
                animateCard(card: nextCardsToAnimate[1], from: .removedStack, to: .next2Card)
                animateCard(card: nextCardsToAnimate[0], from: .removedStack, to: .nextCard)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
                    self.nextCardImageView.isHidden = false
                    self.next2CardImageView.isHidden = false
                }
            default:
                animateCard(card: nextCardsToAnimate[0], from: .removedStack, to: .nextCard)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
                    self.nextCardImageView.isHidden = false
                }
            }
        }
    }
    
    func oneCardLeft() {
        let cards = [nextCards[0]]
        animateNextCards(cards: cards)
    }
    
    func twoCardsLeft() {
        let cards = [nextCards[0], nextCards[1]]
        animateNextCards(cards: cards)
    }
    
    
    func animateNextCards() {
        if gameStatus != .placing {
            return
        }
        
        switch deck.count {
        case 0 :
            switch nextCards.count {
            case ...0:
                nextCardImageView.image = UIImage(named: spotImageName)
            case 1:
                oneCardLeft()
            case 2:
                twoCardsLeft()
            case 3:
//                twoCardsLeft()
                animateNextCards(cards: nextCards)
            default:
                return
            }
        case (deckString?.count ?? 52 * 3) / 3:
            Utilities.log("(deckString?.count ?? 52 * 3) / 3")
        default:
            animateNextCards(cards: nextCards)
        }
    }
    
    
    func requestNextCard(firstCard: Bool) {
        
        if !firstCard {
            cardsLeft = cardsLeft! - 1
            enableOptionSpots()
        }

        switch deck.count {
        case 0 :
            switch nextCards.count {
            case 0:
                print("CASE 0:", deck.count, nextCards.count)

                nextCardImageView.image = UIImage(named: spotImageName)
            case 1:
                print("CASE 1:", deck.count, nextCards.count)
                
//                nextCardImageView.isHidden = true
                nextCards.remove(at: 0)
            case 2:
                print("CASE 2:", deck.count, nextCards.count)
                nextCards.remove(at: 0)
            case 3:
                print("CASE 3:", deck.count, nextCards.count)
                nextCards.remove(at: 0)
            default:
                print("CASE default:", deck.count, nextCards.count)
                return
            }
        // First
        case (deckString?.count ?? 52 * 3) / 3:
            nextCards = [deck.remove(at: 0), deck.remove(at: 0), deck.remove(at: 0)]
                        
            let cardsImageNames = nextCards.map { (card) -> String in
                return card.imageName
            }
            
            nextCardImageView.image = UIImage(named: cardsImageNames[0])
            next2CardImageView.image = UIImage(named: cardsImageNames[1])
            next3CardImageView.image = UIImage(named: cardsImageNames[2])

        default:
            nextCards.remove(at: 0)
            nextCards.append(deck.remove(at: 0))
        }
        
        enableOptionSpots()
    }
    
}


extension UIView {
    func addShadow(with radius: CGFloat) {
        
        return

        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = radius

        self.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}


//extension UIStackView {
//    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let frame = self.bounds.insetBy(dx: -30, dy: -30);
//        return frame.contains(point) ? self : nil;
//    }
//}
