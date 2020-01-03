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
enum StatDimension {
    case all, tenSumMode, elevenSumMode, withHints, withoutHints
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










