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
    var timer: Timer = Timer()
    var secondsPassed: Int = 0
    
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
    var viewFinishedLoading: Bool = false
    
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
        
        addRemovalButtonsRecognizer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        updateUI()
        
        let viewingMode = getViewingMode()
        if viewingMode == .onboarding {
            performSegue(withIdentifier: "goToHowTo", sender: nil)
            defaults.set(true, forKey: "firstGamePlayed")
            
//            // TODO: Verify that this is a good place and a way to create uuids
//            defaults.set(UUID().uuidString, forKey: "uuid")
        }
        
        if !viewFinishedLoading {
            startNewGame()
            viewFinishedLoading = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            if let navigationController = segue.destination as? UINavigationController,
                let settingsVC = navigationController.viewControllers.first as? SettingsVC {
                settingsVC.gameDifficulty = difficulty
            }
        }
    }
    
    /// Sets the view controller as the delegate of other controllers.
    func setDelegates() {
        spotsCollectionView.delegate = self
        spotsCollectionView.dataSource = self
        tabBar.delegate = self
    }
    

}

// MARK: - UI
extension GameVC {
    /// Gathers all UI functions for initializing the views
    func updateUI() {
        updateViews()
        updateTabBarUI()
        updateRemoveLabelsUI()
        configureNextCardsUI()
    }
    
    /// Updates the appearance of the spots grid and the bottom view.
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
    
    /// Sets the remove screen labels & background UI
    func updateRemoveLabelsUI() {
        let radius: CGFloat = (removeLabelsBackground.frame.width / 2)
        removeLabelsBackground.roundCorners([.allCorners], radius: radius)
        removeLabelsBackground.backgroundColor = .black
        removeLabelsBackground.alpha = 0.7
        
        removeLabelsBackground.layer.borderColor = UIColor.white.cgColor
        
        removalSumLabel.textColor = .white
        removalSumLabel.layer.zPosition = 4
        removalSumTitleLabel.textColor = .white
        removalSumTitleLabel.layer.zPosition = 4//.alpha = 1
    }
    
    /// Updates the TabBar UI
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
}


// MARK: - TabBar
extension GameVC {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 1:
            
            // Prepare for segue is called before performing the segue so the difficulty is passed to the NewSettingsVC
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
                showAlert(title: "Try again", message: "Start a new game!", dismissText: "Nevermind", confirmText: "Sure", because: .gameLost)
            case .won:
                showAlert(title: "Play again", message: "Start a new game!", dismissText: "Nevermind", confirmText: "Sure", because: .gameWon)
            default:
                showAlert(title: "New Game?", message: "Are you sure you want to start a new game?", dismissText: "Nevermind", confirmText: "Yes", because: .newGame)
            }
        default:
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.tabBar.selectedItem = nil
        }
        
    }

}

// MARK: - CollectionView
extension GameVC {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    /// Creates the spot for a specific IndexPath.
    /// - Parameters:
    ///   - collectionView: The spots' collection view
    ///   - indexPath: The spot's location
    /// - Returns: A cell of type CardCollectionViewCell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let spot = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        spot.initializeSpot(with: nil, at: indexPath)

        return spot
    }
    
    /// Calls when a spot was tapped. Acts differently based on the game status (placing, removing, game over, win).
    /// - Parameters:
    ///   - collectionView: The spots collection view
    ///   - indexPath: The selected spot's IndexPath
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
                
        let edgeInsets = (self.view.frame.size.width - (4 * cardWidth)) / (4 + 1)
        
        return UIEdgeInsets(top: 5.0, left: edgeInsets, bottom: 5.0, right: edgeInsets)
    }
    
    /// Calculates the size of each spot.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
        cardHeight = collectionView.frame.height / 4 - 10
        cardWidth = cardHeight / 3 * 2

        return CGSize(width: cardWidth, height: cardHeight)
    }

}

// MARK: - Animating
extension GameVC {
    /// Animates a card from a spot to another spot
    /// - Parameters:
    ///   - card: The card to animate
    ///   - origin: The origin spot's IndexPath
    ///   - destination: The destination spot's IndexPath
    func animateCard(card: Card, from origin: IndexPath, to destination: IndexPath) {
        animateCard(card: card, from: origin as Any, to: destination as Any)
    }
    
    /// Animates a card from a spot to a different location (next cards / removed stack)
    /// - Parameters:
    ///   - card: The card to animate
    ///   - origin: The origin spot's IndexPath
    ///   - destination: The destination location
    func animateCard(card: Card, from origin: IndexPath, to destination: CardAnimationLocation) {
        animateCard(card: card, from: origin as Any, to: destination as Any)
    }
    
    /// Animates a card from a location (next cards / removed stack) to a spot
    /// - Parameters:
    ///   - card: The card to animate
    ///   - origin: The origin location
    ///   - destination: The destination spot's IndexPath
    func animateCard(card: Card, from origin: CardAnimationLocation, to destination: IndexPath) {
        animateCard(card: card, from: origin as Any, to: destination as Any)
    }
    
    /// Animates a card from a location (next cards / removed stack) to another location
    /// - Parameters:
    ///   - card: The card to animate
    ///   - origin: The origin location
    ///   - destination: The destination location
    func animateCard(card: Card, from origin: CardAnimationLocation, to destination: CardAnimationLocation) {
        animateCard(card: card, from: origin as Any, to: destination as Any)
    }

    
    /// Animates a card from a location/spot to a location/spot by creating a new image view and move it from origin to destination.
    /// - Parameters:
    ///   - card: The card to animate
    ///   - origin: The origin of the card
    ///   - destination: The destination of the card
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
    
    /// Gets the frame for a location.
    ///
    /// Possible locations:
    /// * IndexPath - The frame of the spot at the index path
    /// * Next 1/2/3 card
    /// * Removed cards stack (outside of screen)
    /// - Parameter location: The location to get the frame of. Should be of type IndexPath or CardAnimationLocation.
    /// - Returns: The frame of the location.
    func getFrame(for location: Any) -> CGRect {

        var point : CGPoint = CGPoint()
        var size : CGSize = CGSize()
        
        
        if let indexPath = location as? IndexPath {
            let spot = getSpot(at: indexPath)
            
            point = spot.superview?.convert(spot.frame.origin, to: nil) ?? point
            size = spot.frame.size
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
}

// MARK: - Highlighting
extension GameVC {
    /// Enables (highlights) all empty spots that are available for the next card.
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
    
    /// Enables (highlights) option cards for a card.
    /// - Parameters:
    ///   - indexPath: The card's index path. If nil, disable all cards except for specific conditions
    ///   - enableAll: True if enable all cards, false otherwise
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
    
    /// Gets the index paths of the spots that have cards
    /// - Parameter placed: Whether to get all placed spots or empty spots
    /// - Returns: The spots' index paths
    func getPlacedIndexPaths(placed: Bool) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for spot in getAllSpots() {
            if spot.isEmpty != placed {
                indexPaths.append(spot.indexPath!)
            }
        }
        return indexPaths
    }

    /// Gets the index paths of the spots that are selected
    /// - Parameter placed: Whether to get all selected spots or not selected spots
    /// - Returns: The spots' index paths
    func getSelectedIndexPaths(selected: Bool) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for spot in getAllSpots() {
            if spot.isSpotSelected == selected {
                indexPaths.append(spot.indexPath!)
            }
        }
        return indexPaths
    }
    
    /// Gets the cards that can be pairs with a certain card for removal.
    /// - Parameter indexPath: The card's index path
    /// - Returns: The index paths of the cards that can be paired.
    func getCardsToPairWith(cardAt indexPath: IndexPath) -> [IndexPath] {
        let selectedSpot = getSpot(at: indexPath)
        let selectedCard = selectedSpot.card!
        var optionsIndexPaths: [IndexPath] = []
        
        for spot in getAllSpots() {
            if let card = spot.card {
                if selectedCard.rank!.getRawValue() + card.rank!.getRawValue() == difficulty.sumMode.getRawValue() {
                    let indexPathToAdd = spot.indexPath!
                    if indexPathToAdd != indexPath {
                        optionsIndexPaths.append(spot.indexPath!)
                    }
                }
            }
        }
        
        return optionsIndexPaths
    }
    
}

// MARK: - UI
extension GameVC {
    /// Updates the cards left label with the current value
    func updateCardsLeftLabel() {
        cardsLeftLabel.text = "CARDS LEFT: \(cardsLeft ?? 0)"
    }
    
    /// Gets how much rotation the next cards need to have, depending on the number of next cards to display.
    /// - Parameter location: The location to get the rotation for
    /// - Returns: The rotation angle
    func getRotationForLocation(location: CardAnimationLocation) -> CGFloat {
        
        let rotationAngle: CGFloat = 0.2
        
        switch difficulty.numberOfNextCards {
        case 3:
            switch location {
            case .nextCard:
                return rotationAngle
            case .next3Card:
                return -rotationAngle
            default:
                return 0
            }
        case 2:
            switch location {
            case .nextCard:
                return rotationAngle
            case .next2Card:
                return -rotationAngle
            default:
                return 0
            }
        default:
            return 0
        }
    }

}

// MARK: - Placing Functions
extension GameVC {
    
    // TODO: Rename function? It's also called when done removing.
    /// Called when a card was placed or when done removing. It checks if game mode needs to be changed.
    /// - Parameter cardPlaced: Whether a card was placed or not (to know if to animate the next cards)
    func finishedPlacingCard(cardPlaced: Bool) {
        
        checkAvailability()
        
        let boardFull = isBoardFull()
        let cardsToRemove = getCardsToRemove().count > 0
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
        
        if cardPlaced {
            animateNextCards()
        }
    }
    
    /// Checks if the next card can be put at the spot and does it if so.
    /// - Parameter indexPath: The spot's IndexPath
    /// - Returns: True if the card was placed, false otherwise
    func placeCard(at indexPath: IndexPath) -> Bool {
        
        if nextCards.count < 1 {
            return false
        }
        
        let spot = getSpot(at: indexPath)

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
            spot.setCard(nextCards[0])
            let move = GameMove(cards: [nextCards[0]], indexPaths: [indexPath], moveType: .place)
            moves.append(move)
            haptic(.placeSuccess)
            
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
            
            haptic(.placeError)

            blockedCardTaps += 1
            
            if blockedCardTaps > 2 {
                self.showHints(hintType: .tappedTooManyTimes)
            }
        }
        
        return false
    }

}

// MARK: - Removal Functions
extension GameVC {
    
    
    
    /// Enables/Disable the Remove button
    /// - Parameter enable: True if enable, false if disable
    func enableRemoveButton(enable: Bool) {
        removeBtn.isEnabled = enable
        removeIcon.alpha = enable ? 1 : 0.5
        removeIcon.isUserInteractionEnabled = enable
        removeAreaStackView.isUserInteractionEnabled = enable
    }
    
    /// Adds gesture recognizer to removal screen buttons so they will react to taps.
    func addRemovalButtonsRecognizer() {
        let removeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removePressed(_:)))
        removeIcon.addGestureRecognizer(removeGestureRecognizer)
        removeAreaStackView.addGestureRecognizer(removeGestureRecognizer)

        let doneRemovingGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneRemovingPressed(_:)))
        doneRemovingIcon.addGestureRecognizer(doneRemovingGestureRecognizer)
        doneRemovingAreaStackView.addGestureRecognizer(doneRemovingGestureRecognizer)

    }
    
    /// Switches between showing and hiding the removal mode UI
    /// - Parameter show: True if show removal mode UI, false otherwise
    func showRemovalUI(show: Bool) {
        doneRemovingBtn.isHidden = !show
        doneRemovingIcon.isHidden = !show
        removeIcon.isHidden = !show
        removeBtn.isHidden = !show
        enableRemoveButton(enable: false)
        enableDoneRemovingButton(enable: false)
        removeLabelsView.isHidden = !show
        removalSumLabel.adjustsFontSizeToFitWidth = true
        removalSumLabel.minimumScaleFactor = 0.2
        
        hideNextCardsWithAnimation(hide: show)
        
        if show {
            enableOptionCards(forCardAt: nil)
        }
    }
    
    /// Enables/Disable the Done Removing button
    /// - Parameter enable: True if enable, false if disable
    func enableDoneRemovingButton(enable: Bool) {
        
        var shouldEnableBySetting = false
        let cardsToRemove = getCardsToRemove()
        
        if difficulty.doneRemovingAnytime {
            if !isBoardFull() {
                shouldEnableBySetting = true
            }
        } else if cardsToRemove.count == 0 {
            shouldEnableBySetting = true
        }
        
        let finalDecision = shouldEnableBySetting && enable
        
        doneRemovingBtn.isEnabled = finalDecision
        doneRemovingIcon.alpha = finalDecision ? 1 : 0.5
        doneRemovingIcon.isUserInteractionEnabled = finalDecision
        doneRemovingAreaStackView.isUserInteractionEnabled = finalDecision
    }
    
    
    /// Called when **Remove** button is pressed.
    /// The function checks whether one card or two cards are selected, and removes them if they are summed to 10 or 11 (depending on the mode).
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
                haptic(.removeError)
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
                haptic(.removeError)
                Toast.show(message: "Can't remove cards that don't sum to \(difficulty.sumMode.getRawValue())", controller: self)
            }
        }
                
        resetCardIndexes()
        
        markCardAsSelected(at: nil)
        enableOptionCards(forCardAt: nil)
        
        finishedRemovingCard()
    }
    
    /// Removes cards from the board.
    /// - Parameter indexPaths: The IndexPaths of the spots to remove cards from.
    func removeCards(at indexPaths: [IndexPath]) {
        var newlyRemovedCards = [Card]()
        var cardsLocations = [IndexPath]()
        
        for indexPath in indexPaths {
            let spot = getSpot(at: indexPath)
            let card = spot.card!
            playSound(.removeCard)
            haptic(.removeSuccess)
            newlyRemovedCards.append(card)
            cardsLocations.append(indexPath)
            spot.removeCard()
        }
        
        enableRemoveButton(enable: false)
        enableDoneRemovingButton(enable: true)
        
        let move = GameMove(cards: newlyRemovedCards, indexPaths: cardsLocations, moveType: .remove)
        moves.append(move)
    }
    
    /// Called when **Done** button is pressed.
    /// Switches between removing and placing game modes and deselects all cards.
    @IBAction func doneRemovingPressed(_ sender: Any) {
        finishedPlacingCard(cardPlaced: false)
        
        markCardAsSelected(at: nil)
        enableOptionSpots()
    }
    
    /// Resets both selected cards index paths.
    func resetCardIndexes() {
        firstSelectedCardIndexPath = nil
        secondSelectedCardIndexPath = nil
    }
    
    
    /// Handles what happens after pressed remove.
    /// The function checks if it is the case of a full frame with middle cards that can't be removed (whilst no more cards in the deck) and if so it sets the game as over.
    func finishedRemovingCard() {
        
        let cardsToRemove = getCardsToRemove()

        if cardsToRemove.count == 0 && getSettingValue(for: .highlightAvailableMoves) {
            Toast.show(message: "No more cards to remove. Tap done", controller: self)
        }
        
        let cardsAtCenter = getEmptySpots(atCenter: true)
        
        if let cardsLeft = cardsLeft {
            if cardsLeft == 0 && cardsToRemove.count == 0 && cardsAtCenter.count != 4 {
                setGameStatus(status: .gameOver)
                setNextCardsImages(next1ImageName: spotImageName, next2ImageName: nil, next3ImageName: nil)
            } else {
            }
        }
    }
    
    /// Checks what card are already selected and selects/deselects accordingly.
    /// - Parameter indexPath: The tapped spot's IndexPath
    func selectCardForRemoval(at indexPath: IndexPath) {
        
        // TODO: Improve syntax, too many repeating lines
        
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
}

// MARK: - Game End
extension GameVC {
    /// Called when the game is over
    /// - Parameter toAddStats: Whether to add the stats or not (in case of recurring winning feedback for the same game)
    func gameOver(toAddStats: Bool) {
        
        stopTimer()
        didWin = false
        gameOverFeedback()
        
        if let cardsLeft = cardsLeft {
            if cardsLeft > 0 && !difficulty.hideNextCardsWhenRemoving {
                showNextCards()
            }
        }
        enableOptionCards(forCardAt: nil, enableAll: true)

        if toAddStats {
            addStats(because: .gameLost)
        }
    }
    
    /// Feedback a game loss
    func gameOverFeedback() {
        gameLoseReason = getLoseReason()
        let loseReasonText = getLoseReasonText(loseReason: gameLoseReason)
        let statsText = getGameStatsText()
        let messageText = "\(loseReasonText)\n\n\(statsText)"

        playSound(.lose)
        haptic(.gameOver)
        showAlert(title: "Game Over", message: messageText, dismissText: "OK", confirmText: "Start a new game", because: .gameLost)
    }
    
    /// Creates a string of basic game stats.
    ///
    /// Stats:
    /// 1. Cards left
    /// 1. Time passed
    /// - Returns: The text for the stats.
    func getGameStatsText() -> String {
        var cardsLeftText = ""
        if cardsLeft != nil && cardsLeft! > 0 {
            cardsLeftText = "Cards Left: \(cardsLeft!)"
        }
        
        let timeText = "Time: \(Utilities.formatSeconds(seconds: secondsPassed))"
        let statsText = "\(timeText)\n\(cardsLeftText)"
        return statsText
    }
    
    /// Called in case the game is won.
    /// - Parameter toAddStats: Whether to add the stats or not (in case of recurring winning feedback for the same game)
    func gameWon(toAddStats: Bool) {
        stopTimer()
        
        playSound(.win)
        confetti()
        haptic(.win)
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
        
                
        showAlert(title: title, message: messageText, dismissText: "Great", confirmText: "Start a new game", because: .gameWon)
        
//        setNextCardsImages(next1ImageName: spotImageName, next2ImageName: nil, next3ImageName: nil)
        enableOptionCards(forCardAt: nil, enableAll: true)
        
        if toAddStats {
            addStats(because: .gameWon)
        }
    }
    
    /// Checks why the game was lost
    /// - Returns: The LoseReason of the game
    func getLoseReason() -> LoseReason {
        let cardsToRemove = getCardsToRemove()
        if cardsToRemove.count == 0 && isBoardFull() {
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
    
    /// Creates a text for the LoseReason
    /// - Parameter loseReason: The LoseReason to create string of.
    /// - Returns: The formatted text for the lose reason.
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
    
    /// Shows alert for game ends (win/lose) with *OK* and *Restart* actions.
    /// - Parameters:
    ///     - title: The title of the alert
    ///     - message: The message of the alert
    ///     - dismissText: Text for dismiss button
    ///     - confirmText: Text for confirm button
    func showAlert(title: String, message: String, dismissText: String, confirmText: String, because reason: StatAddingReason) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let restartAction = UIAlertAction(title: confirmText, style: .default) { (action) in
            self.stopTimer()
            self.restartAfter = true
            self.addStats(because: reason)
            self.startNewGame()
        }
        let okAction = UIAlertAction(title: dismissText, style: .cancel, handler: nil)

        alert.addAction(okAction)
        alert.addAction(restartAction)

        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Stats
extension GameVC {
    
    /// Adds the game stats to the context.
    func addStats(because reason: StatAddingReason) {
        
        var loseReason = ""
        switch reason {
        case .gameLost:
            loseReason = gameLoseReason.getRawValue()
        case .gameWon:
            loseReason = "gameWon"
        case .newGame, .newGameWithNewDifficulty:
            loseReason = reason.getRawValue()
        }
        
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
            gameStatsToAdd.loseReason = loseReason
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
            gameStatsToAdd.appVersion = defaults.string(forKey: "appVersion")
            
            let synced = uploadStats(forGame: gameStatsToAdd)
            gameStatsToAdd.synced = synced
        }
        
        saveStats()
    }
    
    /// Save the stats that are staged in the context.
    func saveStats() {
        do {
            try context.save()
        } catch {
            Utilities.log("Error saving context: \(error)")
        }
    }
    
    /// Gets the stats for a gameID
    /// - Parameter gameID: The gameID to get the stats for
    /// - Returns: The game object with all the stats
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
    
    /// Creates the stats to upload and uploads them to both user and game paths in Firebase
    /// - Parameter game: The game object
    /// - Returns: True if the game was uploaded to both user and game paths, false otherwise
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
                "synced": true,
                "appVersion": game.appVersion as Any
            ]
            
            let uuid = defaults.string(forKey: "uuid")

            var dataToAddUser = dataToAdd
            dataToAddUser["gameID"] = game.gameID!.uuidString
            
            var dataToAddGame = dataToAdd
            dataToAddGame["userID"] = uuid
            
            let gameDataUploaded = uploadStats(referenceString: "games/\(game.gameID!)", dataToAdd: dataToAddGame)
            let userDataUploaded = uploadStats(referenceString: "users/\(uuid!)/games/\(game.gameID!)", dataToAdd: dataToAddUser)
            
            if game.didWin {
                let winDataUploaded = uploadStats(referenceString: "wins/\(game.gameID!)", dataToAdd: dataToAddGame)
                statsUploaded = gameDataUploaded && userDataUploaded && winDataUploaded
            } else {
                statsUploaded = gameDataUploaded && userDataUploaded
            }
        }
        return statsUploaded
    }
    
    /// Uploads stats to Firebase
    /// - Parameters:
    ///   - referenceString: The document reference string
    ///   - dataToAdd: The data to upload
    /// - Returns: True if the stats were uploaded, false otherwise
    func uploadStats(referenceString: String, dataToAdd: [String: Any]) -> Bool {
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
    
    /// Gets the fastest win duration yet
    /// - Returns:The duration of the fastest win in seconds. If there is no win, returns nil.
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

}

// MARK: - Spots Handling
extension GameVC {
    
    /// Gets the number of cards that are currently placed on the board
    /// - Parameter rank: The rank of which to count placed cards
    /// - Returns: The numebr of cards of the specified rank placed on the board
    func getNumberOfCardsPlaced(withRank rank: CardRank) -> Int {
        var nofCards : Int = 0
        for spot in getAllSpots() {
            if let card = spot.card {
                if card.rank! == rank {
                    nofCards += 1
                }
            }
        }
        return nofCards
    }
    
    /// Removes all cards in the board.
    func removeAllCards() {
        for spot in getAllSpots() {
            spot.removeCard()
        }
    }
   
    /// Gets all cells as spots (CardCollectionViewCell)
    func getAllSpots() -> [CardCollectionViewCell] {
        return spotsCollectionView.visibleCells as! [CardCollectionViewCell]
    }

    /// Marks a card as selected. If nil then deselect all cards.
    /// - Parameter indexPath: The cards to mark as selected. If nil then deselect all cards.
    func markCardAsSelected(at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            if let spot = spotsCollectionView.cellForItem(at: indexPath) as? CardCollectionViewCell {
                spot.mark(as: .selected, on: true)
            }
        } else {
            for spot in getAllSpots() {
                if spot.isSpotSelected {
                    spot.mark(as: .selected, on: false)
                }
            }
        }
    }
    
    /// Checks for a certain IndexPath which type of cards should be placed.
    /// - Parameter indexPath: The spot's IndexPath
    /// - Returns: The appropriate AllowedRanks for the sp
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

    /// Filters index paths and returns only the wanted (empty or not)
    /// - Parameters:
    ///   - indexPaths: The index paths to filter
    ///   - empty: True if want only empty spots, false if only not empty spots
    /// - Returns: The filtered index paths
    func filterSpots(indexPaths: [IndexPath], empty: Bool) -> [IndexPath] {
        return indexPaths.filter { (indexPath) -> Bool in
            
            let spot = getSpot(at: indexPath)
            if empty {
                return spot.isEmpty
            } else {
                return !spot.isEmpty
            }
        }
    }
    
    /// Gets the spot (CardCollectionViewCell) for a certain IndexPath
    /// - Parameter indexPath: The IndexPath of the wanted spot
    /// - Returns: The collectionViewCell of the spot
    func getSpot(at indexPath: IndexPath) -> CardCollectionViewCell {
        return spotsCollectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
    }
    
    /// Gets the card at a certain IndexPath
    /// - Parameter indexPath: The IndexPath of the wanted card
    /// - Returns: The card in the spot if it has one, nil otherwise.
    func getCard(at indexPath: IndexPath) -> Card? {
        let spot = getSpot(at: indexPath)
        return spot.card
    }
}

// MARK: - General Game Flow
extension GameVC {
    
    /// Changes the game status, changes the UI accordingly and calls functions that acts according to the new game status.
    /// - Parameter status: The game status to set
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
    
    /// Starts a new game
    func startNewGame() {
            
        // Get game settings
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
        didWin = false
        
        moves = []
        
        // Get deck
        deck = model.getDeck(ofType: .regularDeck, random: true, from: nil, fullDeck: nil)
//        deck = model.getDeck(ofType: .onlyRoyals, random: false, from: nil, fullDeck: nil)
//        deck = model.getDeck(ofType: .notRoyals, random: false, from: nil, fullDeck: nil)
//        deck = model.getDeck(ofType: .fromString, random: false, from: "h10d05c10c05h13c13d13s13h12c12d12s12h11c11d11s11h04c01", fullDeck: false)

        deckString = model.getDeckString(deck: deck)
        cardsLeft = deck.count
        
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

        Utilities.log("Started new game \(gameID.uuidString)")
    }
}

// MARK: - Game validations
extension GameVC {
    /// Checks if the next card's spot is taken.
    /// - Returns: True if the next card is blocked, false otherwise
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
    
    /// Checks if the board is full (all spots are taken).
    /// - Returns: True if the board is full, false otherwise
    func isBoardFull() -> Bool {
        for spot in getAllSpots() {
            if spot.isEmpty {
                return false
            }
        }
        return true
    }

    /// Checks what spots are available and updates the relevant properties
    func checkAvailability() {
        kingsAvailable = 0
        queensAvailable = 0
        jacksAvailable = 0
        spotsAvailable = 0
        
        for spot in getAllSpots() {
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
        }
        spotsAvailable = spotsAvailable + jacksAvailable + queensAvailable + kingsAvailable
    }
    
    /// Checks whether the game was completed and the user have won.
    /// Game is won if all royal cards are placed at appropriate place and no cards are in the center.
    /// - Returns: True if the user won the game, false otherwise
    func isGameWon() -> Bool {
        
        for spot in getAllSpots() {
            
            let allowedRanks = getDesignatedRanksByPosition(indexPath: spot.indexPath!)
            // If the spot contains a card that does not match it's designated rank, the function returns false.
            if let card = spot.card {
                let cardRank = card.rank!
                if (allowedRanks == .jacks && cardRank != .jack) || (allowedRanks == .queens && cardRank != .queen) || (allowedRanks == .kings && cardRank != .king) || (allowedRanks == .notRoyal && !difficulty.canWinWithCardsAtTheCenter) {
                    return false
                }
            // If there is no card at the spot and it is a royal spot, the function returns false.
            } else if allowedRanks != .notRoyal{
                return false
            }
        }
        
        return true
    }
    
    /// Checks whether the user lose. It's using the nextCard so must be called after a turn.
    ///
    /// Game is over if board is full and there are no cards that can be removed or if the next card is royal and it's spots are taken
    /// - Returns: True if the game is over, false otherwise
    func isGameOver() -> Bool {
        
        let boardFull = isBoardFull()
        let cardsToRemove = getCardsToRemove()
        let nextCardRank = nextCards[0].rank!
        
        // If the board is full and there are no cards to remove
        if boardFull && cardsToRemove.count == 0 {
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
    
    /// Checks whether the next card can be placed at a spot on the board.
    /// - Parameters:
    ///   - card: The card to check
    ///   - indexPath: The designated spot to place the card at
    /// - Returns: True if the card can be placed at the spot, false otherwise
    func canPutCard(_ card: Card, at indexPath: IndexPath) -> Bool {
        // If the spot is empty then check whether the spot position and the card rank fit
        
        let spot = getSpot(at: indexPath)
        if spot.isEmpty {
            
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
}

// MARK: - Undo
extension GameVC {
    /// Undos the previous move if it's allowed by setting. Also handles animation.
    /// Can't undo when switching between modes (placing, removing, game over/win)
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
                    
                    let spot = getSpot(at: indexPath)
                    
                    animateCard(card: card, from: .removedStack, to: indexPath)
                    
                    spot.setCard(card)
                }
                undosUsed += 1
            case .place:
                if gameStatus != .placing {
                    moves.append(lastMove)
                    return
                }
                for (card, indexPath) in zip(lastMove.cards, lastMove.indexPaths) {
                    let spot = getSpot(at: indexPath)
                    
                    animateCard(card: card, from: indexPath, to: .nextCard)
                    
                    spot.removeCard()
                    deck.insert(nextCards[0], at: 0)
                    nextCards[0] = card
                    cardsLeft! += 1
                    updateCardsLeftLabel()
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
                        self.setNextCardsImages(next1ImageName: card.imageName, next2ImageName: nil, next3ImageName: nil)
                    }
                }
                undosUsed += 1
            }
        }
        
    }
}

// MARK: - Hints
extension GameVC {
    
    /// Generates hints for the current board and next card and shows them on the board
    /// - Parameter hintType: The reason of the hint (User asked for it, waited too long, made mistakes)
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
    
    /// Changes the spot's UI to hint
    /// - Parameter indexPath: The card index path
    func hintCard(at indexPath: IndexPath) {
        let spot = getSpot(at: indexPath)
        spot.mark(as: .hint, on: true)
    }
    
    /// Gets the spots to hint.
    ///
    /// Logic:
    /// * When placing cards, it hints:
    ///     * Designated spots for the royal cards
    ///     * Center spots if available
    ///     * Royal with most empty spots
    /// * When removing cards, it takes a random pair of cards to remove.
    /// - Returns: The hinted spots' index paths
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
                    // If the next card is royal
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
    
    /// Gets the empty spots to hint.
    /// - Parameter atCenter: True if want to search empty spots in the center, false otherwise
    /// - Returns: The list of empty index paths
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
    
    /// Gets cards that can be removed when paired.
    /// - Parameter randomElement: True if want only one pair (or 10), false if want all cards that can be removed.
    /// - Returns: Index paths of the cards that can be removed.
    func getCardsToRemove(_ randomElement: Bool = true) -> [IndexPath] {
        var cardsSpots = [IndexPath]()
        
        var allPairs = [[IndexPath]]()
        
        let allSpots = getAllSpots()
        
        for spot1 in allSpots {
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
                    for spot2 in allSpots {
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
}

// MARK: - Timer
extension GameVC {
    /// Called everytime the times elapses, increments the game duration by one second and updates the time label.
    @objc func timerElapsed() {
        // If another view controller is presented than pause the timer
        if presentedViewController == nil {
            secondsPassed += 1
            updateTimeLabel()
        }
    }
    
    /// Formats the time label and changes its text.
    func updateTimeLabel() {
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
    
    /// Creates the timer and connects it to the timerElapsed method
    func addTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
    }
    
    /// Invalidates the time
    func stopTimer() {
        if timer.isValid == true {
            timer.invalidate()
        }
    }
}

// MARK: - Feedbacks
extension GameVC {
    /// Plays a sound
    /// - Parameter sound: The type of the sound to play
    func playSound(_ sound: SoundType) {
        let soundFileFullName = sound.getRawValue()
        
        let soundsOn = getSettingValue(for: .soundsOn)
        if !soundsOn {
            return
        }

        let soundFileName = String(soundFileFullName.split(separator: ".")[0])
        let soundFileExtension = String(soundFileFullName.split(separator: ".")[1])
        
        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: soundFileExtension) else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly */
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            Utilities.log(error.localizedDescription)
        }
    }
    
    /// Make a haptic feedback
    /// - Parameter feedbackType: The type of the feedback
    func haptic(_ feedbackType: HapticFeedbackType) {
        
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
        case .win:
            hapticGenerator.notificationOccurred(.success)
        }
    }
}

// MARK: - Confetti
extension GameVC {
    /// Gets a random number
    /// - Parameter limit: The top limit of the random number range
    /// - Returns: The random number
    private func getRandomNumber(_ limit: Int) -> Int {
        return Int(arc4random_uniform(UInt32(limit)))
    }
    
    /// Creates confetti cells
    /// - Returns: An array of the confetti cells
    func generateEmitterCells() -> [CAEmitterCell] {
        
        let confettiImages: [UIImage] = [
            UIImage(named: "confetti-diamond.png")!,
            UIImage(named: "confetti-club.png")!,
            UIImage(named: "confetti-heart.png")!,
            UIImage(named: "confetti-spade.png")!,
            UIImage(named: "confetti-crown.png")!
        ]
        
        let velocities: [Int] = [
            100
            , 500
            , 90
            , 900
            , 200
            , 150
            , 720
        ]
        
        var cells: [CAEmitterCell] = [CAEmitterCell]()
        for index in 0..<confettiImages.count * 2 {
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
    
    /// Throw confetti!
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
}

// MARK: - Settings
extension GameVC {
    
    /// Checks if a setting exists in user defaults
    /// - Parameter settingKey: A key that represents the setting to check the data for.
    /// - Returns: True if the setting exists, false otherwise
    func isSettingExists(settingKey: SettingKey) -> Bool {
        let currentlySavedKeys = defaults.dictionaryRepresentation().keys
        return currentlySavedKeys.contains(settingKey.getRawValue())
    }
    
    /// Sets default setting for boolean settings.
    /// - Parameter settingKey: A key that represents the setting to set the default for.
    /// - Returns: The default value for the settingKey
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
    
    /// Gets the setted value for boolean settings. If the key doesn't exist it sets the default value for that setting and returns it.
    /// - Parameter settingKey: A key that represents the setting to get the value for.
    /// - Returns: The value for the settingKey
    func getSettingValue(for settingKey: SettingKey) -> Bool {
        let keyExists = isSettingExists(settingKey: settingKey)
        if keyExists {
            return defaults.bool(forKey: settingKey.getRawValue())
        } else {
            return setDefaultSetting(for: settingKey)
        }
    }
    
    /// Gets the setted difficulty
    /// - Returns: The setted difficulty
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
        
        return Difficulty(from: difficultyString)
    }
    
    /// Gets the viewing mode for the tutorial
    /// - Returns: Onboarding if first game, regular tutorial otherwise
    func getViewingMode() -> OnboardingViewingMode {
        let firstGame = !defaults.bool(forKey: "firstGamePlayed")
        
        if firstGame {
            return .onboarding
        } else {
            return .howTo
        }
    }
}

// MARK: - Next card handling
extension GameVC {
    
    /// Requesting the next card from the deck and handles placing it (and the other next cards) in the next cards image views.
    /// - Parameter firstCard: Whether this is the first card of the deck
    func requestNextCard(firstCard: Bool) {
        
        if !firstCard {
            cardsLeft = cardsLeft! - 1
            enableOptionSpots()
        }

        switch deck.count {
        case 0 :
            switch nextCards.count {
            case 0:
                setNextCardsImages(next1ImageName: spotImageName)
            case 1:
                nextCards.remove(at: 0)
            case 2:
                nextCards.remove(at: 0)
            case 3:
                nextCards.remove(at: 0)
            default:
                return
            }
        // First
        case (deckString?.count ?? 52 * 3) / 3:
            nextCards = [deck.remove(at: 0), deck.remove(at: 0), deck.remove(at: 0)]
                        
            let cardsImageNames = nextCards.map { (card) -> String in
                return card.imageName
            }
            
            setNextCardsImages(next1ImageName: cardsImageNames[0], next2ImageName: cardsImageNames[1], next3ImageName: cardsImageNames[2])

        default:
            nextCards.remove(at: 0)
            nextCards.append(deck.remove(at: 0))
        }
        
        enableOptionSpots()
    }
    
    /// Handles which cards will be animated.
    func animateNextCards() {
        if gameStatus != .placing {
            return
        }
        
        switch deck.count {
        case 0 :
            switch nextCards.count {
            case ...0:
                setNextCardsImages(next1ImageName: spotImageName)
            //TODO: Do something like this: animateNextCards(cards: nextCards[:nextCards])
            case 1:
                animateNextCards(cards: [nextCards[0]])
            case 2:
                animateNextCards(cards: [nextCards[0], nextCards[1]])
            case 3:
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
    
    /// Hides the next cards when going into removal mode
    /// - Parameter hide: True if hide, false otherwise
    func hideNextCardsWithAnimation(hide: Bool) {
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
                setNextCardsIsHidden(next1: true, next2: true, next3: true)
                
                animateCard(card: nextCardsToAnimate[1], from: .next2Card, to: .removedStack)
                animateCard(card: nextCardsToAnimate[2], from: .next3Card, to: .removedStack)
            case 2:
                setNextCardsIsHidden(next1: true, next2: true)

                animateCard(card: nextCardsToAnimate[1], from: .next2Card, to: .removedStack)
            default:
                setNextCardsIsHidden(next1: true)
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
                            
            setNextCardsImages(next1ImageName: cardsImages[0], next2ImageName: cardsImages[1], next3ImageName: cardsImages[2])

            switch difficulty.numberOfNextCards {
            case 3:
                animateCard(card: nextCardsToAnimate[2], from: .removedStack, to: .next3Card)
                animateCard(card: nextCardsToAnimate[1], from: .removedStack, to: .next2Card)
                animateCard(card: nextCardsToAnimate[0], from: .removedStack, to: .nextCard)

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
                    self.setNextCardsIsHidden(next1: false, next2: false, next3: false)
                }
            case 2:
                animateCard(card: nextCardsToAnimate[1], from: .removedStack, to: .next2Card)
                animateCard(card: nextCardsToAnimate[0], from: .removedStack, to: .nextCard)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
                    self.setNextCardsIsHidden(next1: false, next2: false)
                }
            default:
                animateCard(card: nextCardsToAnimate[0], from: .removedStack, to: .nextCard)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
                    self.setNextCardsIsHidden(next1: false)
                }
            }
        }
    }
    
    /// Sets the isHidden value of the next cards image views.
    /// - Parameters:
    ///   - next1: True if hide, false if show, nil if don't touch
    ///   - next2: True if hide, false if show, nil if don't touch
    ///   - next3: True if hide, false if show, nil if don't touch
    func setNextCardsIsHidden(next1: Bool? = nil, next2: Bool? = nil, next3: Bool? = nil) {
        if next1 != nil {
            nextCardImageView.isHidden = next1!
        }
        if next2 != nil {
            next2CardImageView.isHidden = next2!
        }
        if next3 != nil {
            next3CardImageView.isHidden = next3!
        }
    }
    
    /// Sets the image of the next cards image views.
    /// - Parameters:
    ///   - next1ImageName: The image name of the wanted image, nil if don't touch
    ///   - next2ImageName: The image name of the wanted image, nil if don't touch
    ///   - next3ImageName: The image name of the wanted image, nil if don't touch
    func setNextCardsImages(next1ImageName: String? = nil, next2ImageName: String? = nil, next3ImageName: String? = nil) {
        if next1ImageName != nil {
            nextCardImageView.image = UIImage(named: next1ImageName!)
        }
        if next2ImageName != nil {
            next2CardImageView.image = UIImage(named: next2ImageName!)
        }
        if next3ImageName != nil {
            next3CardImageView.image = UIImage(named: next3ImageName!)
        }
    }
    
    /// Show next cards without animation.
    func showNextCards() {
        
        var cardsImages : [String] = []
        for card in nextCards {
            cardsImages.append("\(card.imageName)")
        }
        
        while cardsImages.count < 3 {
            cardsImages.append(spotImageName)
        }

        setNextCardsImages(next1ImageName: cardsImages[0], next2ImageName: cardsImages[1], next3ImageName: cardsImages[2])

        switch difficulty.numberOfNextCards {
        case 3:
            setNextCardsIsHidden(next1: false, next2: false, next3: false)
        case 2:
            setNextCardsIsHidden(next1: false, next2: false, next3: true)
        default:
            setNextCardsIsHidden(next1: false, next2: true, next3: true)
        }
    }
    
    /// Animates the next cards:
    ///     - 3rd card to 2nd place
    ///     - 2nd card to 1st place
    /// If the there are no card to replace the 3rd/2nd places, the spotImage is being placed (and not animated)
    /// - Parameter cards: The cards to animate (up to 3)
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
    
    /// Sets the UI of the next cards according to the numebr of next cards.
    /// - Rotates the cards
    /// - Moves them horizontally
    /// - Shows/hides them
    /// - Adds shadows
    /// - Saves their center points
    func configureNextCardsUI() {
        
        switch difficulty.numberOfNextCards {
        case 3:
            // Show cards?
            setNextCardsIsHidden(next1: false, next2: false, next3: false)
            
            // Location
            nextCardImageView.transform = CGAffineTransform(translationX: 30, y: 0)
            next2CardImageView.transform = CGAffineTransform.identity
            next3CardImageView.transform = CGAffineTransform(translationX: -30, y: 0)
            
        case 2:
            setNextCardsIsHidden(next1: false, next2: false, next3: true)

            // Location
            nextCardImageView.transform = CGAffineTransform(translationX: 15, y: 0)
            next2CardImageView.transform = CGAffineTransform(translationX: -15, y: 0)

        default:
            setNextCardsIsHidden(next1: false, next2: true, next3: true)

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
}
