//
//  Enums.swift
//  Le Frame
//
//  Created by Saar Botzer on 29/12/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit


// MARK: - Cards
enum CardRank: Int, CaseIterable {
    case ace = 1, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
    
    func getRawValue() -> Int{
        return self.rawValue
    }
    
    static func create(from rawValue: Int) -> CardRank? {
        let cardRanks : [CardRank] = [.ace, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king]
        
        if rawValue > 0 && rawValue < 14 {
            return cardRanks[rawValue - 1]
        } else {
            return nil
        }
        
    }
}

enum DeckType {
    case onlyRoyals, notRoyals, regularDeck, fromString
}

enum CardSuit: String, CaseIterable {
    case heart = "h"
    case diamond = "d"
    case club = "c"
    case spade = "s"
    
    func getRawValue() -> String {
        return self.rawValue
    }
    
    static func create(from rawValue: String) -> CardSuit? {
        switch rawValue {
        case "h":
            return .heart
        case "d":
            return .diamond
        case "c":
            return .club
        case "s":
            return .spade
        default:
            return nil
        }
    }
}

// MARK: - Game related
enum MoveType {
    case place, remove
}

enum StatAddingReason: String {
    case gameLost, gameWon, newGame = "newGame", newGameWithNewDifficulty = "newGameWithNewDifficulty"
    
    func getRawValue() -> String {
        return self.rawValue
    }
}

enum GameLevel {
    case easy
    case normal
    case hard
}

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

enum DesignatedRanks {
    case kings
    case jacks
    case queens
    case notRoyal
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


enum CardAnimationLocation {
    case nextCard, spot, removedStack, next2Card, next3Card
    
    static func getLocationType(at indexPath: IndexPath) -> CardAnimationLocation {
        if indexPath.row == 10 && indexPath.section == 10 {
            return CardAnimationLocation.removedStack
        } else if indexPath.row == -5 && indexPath.section == -5 {
            return CardAnimationLocation.nextCard
        }
        return CardAnimationLocation.spot
    }
}


// MARK: - Settings related

enum OnboardingViewingMode {
    case onboarding, howTo
}

enum SettingKey: String {
    case sumMode = "SumMode"
    case showHints = "ShowHints"
//    case removeWhenFull = "RemoveWhenFull"
    case doneRemovingAnytime = "DoneRemovingAnytime"
    case soundsOn = "SoundsOn"
    case hapticOn = "HapticOn"
    case difficulty = "Difficulty"
    case highlightAvailableMoves = "HighlightAvailableMoves"
    case adsOn = "AdsOn"
    
    func getRawValue() -> String {
        return self.rawValue
    }
}

enum SettingSegue: String {
    case goToStatistics = "goToStatistics"
    case goToAboutUs = "goToAboutUs"
    case goToTutorial = "goToTutorial"
    case goToFaq = "goToFAQ"
    case privacyPolicy = "PrivacyPolicy"
    
    // With no segue
    case share = "share"
    case goToContactUs = "goToContactUs"
    case rateUs = "rateUs"
    
    func getRawValue() -> String {
        return self.rawValue
    }
    
    func hasSegue() -> Bool {
        let withoutSegue = [
            SettingSegue.share,
            SettingSegue.goToContactUs,
            SettingSegue.rateUs
        ]
        
        return !withoutSegue.contains(self)
    }
}

// MARK: - Stats related
enum StatDimension: String {
    case all = "All"
    
    case tenSumMode = "10"
    case elevenSumMode = "11"
    
    case withHints = "With hints"
    case withoutHints = "Without hints"
    
    case veryEasyDifficulty = "Very easy"
    case easyDifficulty = "Easy"
    case normalDifficulty = "Normal"
    case hardDifficulty = "Hard"
    
    func getRawValue() -> String {
        return self.rawValue
    }
}

enum StatMeasure: String {
    case gamesPlayed = "Games played"
        , gamesWon = "Games won"
        , averageGameLength = "Average game length"
        , totalGamesLength = "Total time played"
        , fastestWin = "Fastest win"
        , commonLosingReason = "Mainly lose because of"
        , gamesWithoutHints = "Games without hints"
        , longestWinningStreak = "Longest winning streak"
        , currentWinningStreak = "Current winning streak"
    
    func getRawValue() -> String {
        return self.rawValue
    }
}

enum SoundType: String {
    case win = "win.wav"
    case placeCard = "card-flip-1.wav"
    case removeCard = "card-flip-2.wav"
    case lose = "lose.wav"
    
    func getRawValue() -> String {
        return self.rawValue
    }
}






struct Difficulty: CustomStringConvertible {
    let name: String
    let sumMode: SumMode
    let undosAvailable: Bool
    let doneRemovingAnytime: Bool
    let numberOfNextCards: Int
    let hideNextCardsWhenRemoving: Bool
    let removeAnytime: Bool
    let canWinWithCardsAtTheCenter: Bool
    
    init(
        name: String,
        sumMode: SumMode,
        undosAvailable: Bool,
        doneRemovingAnytime: Bool,
        numberOfNextCards: Int,
        hideNextCardsWhenRemoving: Bool = true,
        removeAnytime: Bool = false,
        canWinWithCardsAtTheCenter: Bool = true
        ) {
        self.name = name
        self.sumMode = sumMode
        self.undosAvailable = undosAvailable
        self.doneRemovingAnytime = doneRemovingAnytime
        self.numberOfNextCards = numberOfNextCards
        self.hideNextCardsWhenRemoving = hideNextCardsWhenRemoving
        self.removeAnytime = removeAnytime
        self.canWinWithCardsAtTheCenter = canWinWithCardsAtTheCenter
    }
    
    init(from string: String) {
        let defaultDifficuly : Difficulty = .default
        var name = defaultDifficuly.name
        var sumMode = defaultDifficuly.sumMode
        var undosAvailable = defaultDifficuly.undosAvailable
        var doneRemovingAnytime = defaultDifficuly.doneRemovingAnytime
        var numberOfNextCards = defaultDifficuly.numberOfNextCards
        var hideNextCardsWhenRemoving = defaultDifficuly.hideNextCardsWhenRemoving
        var removeAnytime = defaultDifficuly.removeAnytime
        var canWinWithCardsAtTheCenter = defaultDifficuly.canWinWithCardsAtTheCenter
        
        let allOptions = Difficulty.allOptions
        for difficultyOption in allOptions {
            if difficultyOption.name == string {
                name = difficultyOption.name
                sumMode = difficultyOption.sumMode
                undosAvailable = difficultyOption.undosAvailable
                doneRemovingAnytime = difficultyOption.doneRemovingAnytime
                numberOfNextCards = difficultyOption.numberOfNextCards
                hideNextCardsWhenRemoving = difficultyOption.hideNextCardsWhenRemoving
                removeAnytime = difficultyOption.removeAnytime
                canWinWithCardsAtTheCenter = difficultyOption.canWinWithCardsAtTheCenter
            }
        }
        
        self.name = name
        self.sumMode = sumMode
        self.undosAvailable = undosAvailable
        self.doneRemovingAnytime = doneRemovingAnytime
        self.numberOfNextCards = numberOfNextCards
        self.hideNextCardsWhenRemoving = hideNextCardsWhenRemoving
        self.removeAnytime = removeAnytime
        self.canWinWithCardsAtTheCenter = canWinWithCardsAtTheCenter
    }
    
    var description: String {
        return self.name
    }
    
    static var activeOptions: [Difficulty] {
        return [.veryEasy, .easy, .normal, .hard]
    }
    
    static var allOptions: [Difficulty] {
        return [.veryEasy, .easy, .normal, .hard]
    }
    
    static var `default`: Difficulty {
        return .normal
    }
    
    static var veryEasy: Difficulty {
        return Difficulty(
            name:                       "veryEasy",
            sumMode:                    .ten,
            undosAvailable:             true,
            doneRemovingAnytime:        true,
            numberOfNextCards:          3,
            hideNextCardsWhenRemoving:  false
        )
    }
    
    static var easy: Difficulty {
        return Difficulty(
            name:                       "easy",
            sumMode:                    .ten,
            undosAvailable:             true,
            doneRemovingAnytime:        true,
            numberOfNextCards:          2,
            hideNextCardsWhenRemoving:  true
        )
    }
    
    static var normal: Difficulty {
        return Difficulty(
            name:                       "normal",
            sumMode:                    .ten,
            undosAvailable:             false,
            doneRemovingAnytime:        false,
            numberOfNextCards:          1,
            hideNextCardsWhenRemoving:  true
        )
    }
    
    static var hard: Difficulty {
        return Difficulty(
            name:                       "hard",
            sumMode:                    .eleven,
            undosAvailable:             false,
            doneRemovingAnytime:        false,
            numberOfNextCards:          1,
            hideNextCardsWhenRemoving:  true
        )
    }
}
