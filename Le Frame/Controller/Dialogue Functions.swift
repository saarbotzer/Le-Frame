//
//  Dialogue Functions.swift
//  Le Frame
//
//  Created by Saar Botzer on 10/10/2020.
//  Copyright © 2020 Saar Botzer. All rights reserved.
//

import UIKit

extension GameVC {
    
    func showDialogue(ofType type: DialogueType) {
        switch type {
        case .onboarding:
            showOnboardingDialogue()
        case .afterTour:
            showAfterTourDialogue(skippedTour: false)
        case .skippedTour:
            showAfterTourDialogue(skippedTour: true)
        case .gameOver, .gameOverRestart:
            showGameOverDialogue(type: type)
        case .gameWon, .gameWonRestart:
            showGameWonDialogue(type: type)
        case .restart:
            showRestartDialogue()
        default:
            break
        }
    }
    
    func showRestartDialogue() {
        // Parameters
        let type: DialogueType = .restart
        
        // Title
        let title = "New Game?"
        
        // Messages
        let message1 = "Are you sure you want to start a new game?"
        let message2 = "All progress will be lost"
        let messages = [message1, message2]
        
        // Buttons
        let button1 = DialogueButton(text: "Yes") { self.restart() }
        let button2 = DialogueButton(text: "Nevermind")
        let buttons = [button1, button2]
        
        // Size
        let height: CGFloat? = nil
        let width: CGFloat? = nil
        let setSize = false
        
        // Payload
        let payload = DialoguePayload(type: type, title: title, messages: messages, buttons: buttons, width: width, height: height, setSize: setSize)
        
        Utilities.presentDialogue(self, payload: payload)
    }
    
    func showGameWonDialogue(type: DialogueType) {
        // Parameters
        let isRestart = type == .gameWonRestart
        var nonRestartTitle = ""
        var nonRestartMessage = ""

        
        if let fastestWinDuration = getFastestWinDuration() {
            if secondsPassed < fastestWinDuration {
                // This win is the fastest
                nonRestartTitle = "Fastest Win!"
                nonRestartMessage = "This is your fastest win yet! Amazing!"
            } else {
                // A regular win
                nonRestartTitle = "You Won!"
                nonRestartMessage = "Good job! You filled the frame with royal cards"
            }
        } else {
            // This is the first win
            nonRestartTitle = "First Win!"
            nonRestartMessage = "Excellent! This is your first win!"
        }
        
        // Title
        let title = isRestart ? "Play again" : nonRestartTitle
        
        // Messages
        let statsText = getGameStatsText()
        
        let message1 = isRestart ? "Start a new game!"  : nonRestartMessage
        let message2 = isRestart ? ""                   : statsText
        let messages = [message1, message2]

        // Buttons
        let button1Title = isRestart ? "Sure"        : "New game!"
        let button2Title = isRestart ? "Nevermind"   : "Great"
        
        let button1 = DialogueButton(text: button1Title, action: { self.restart() })
        let button2 = DialogueButton(text: button2Title, action: nil)
        let buttons = [button1, button2]
        
        // Size
        let width: CGFloat? = 300
        let height: CGFloat? = nil
        let setSize = true
        
        // Payload
        let payload = DialoguePayload(type: type, title: title, messages: messages, buttons: buttons, width: width, height: height, setSize: setSize)
        
        Utilities.presentDialogue(self, payload: payload)
    }
    
    func showGameOverDialogue(type: DialogueType) {
        // Parameters
        let isRestart = type == .gameOverRestart
        
        // Title
        let title = isRestart ? "Try again" : "Game Over"

        // Messages
        gameLoseReason = getLoseReason()
        let loseReasonText = getLoseReasonText(loseReason: gameLoseReason)
        let statsText = getGameStatsText()
        
        let message1 = isRestart ? "Start a new game!"  : loseReasonText
        let message2 = isRestart ? ""                   : statsText
        let messages = [message1, message2]
        
        // Buttons
        let button1Title = isRestart ? "Sure"        : "New game!"
        let button2Title = isRestart ? "Nevermind"   : "OK"
        
        let button1 = DialogueButton(text: button1Title, action: { self.restart() })
        let button2 = DialogueButton(text: button2Title, action: nil)
        let buttons = [button1, button2]
        
        // Size
        let width: CGFloat? = 300
        let height: CGFloat? = nil
        let setSize = true
        
        // Payload
        let payload = DialoguePayload(type: type, title: title, messages: messages, buttons: buttons, width: width, height: height, setSize: setSize)
        
        Utilities.presentDialogue(self, payload: payload)
    }
    
    func showOnboardingDialogue() {
        // Parameters
        let type: DialogueType = .onboarding

        // Title
        let title = "Welcome to Royal Frame"

        // Messages
        let message1 = "Goal: Fill the frame of the board with royal cards"
        let message2 = "Your goal is to fill the frame of the board with royal cards:"
        let message3 = "Let's have a quick tour to show you around"
        let messages = [message1, message2, message3]

        // Buttons
        let button1 = DialogueButton(text: "Start tour", action: { self.coachMarksController.start(in: .window(over: self)) })
        let button2 = DialogueButton(text: "Skip tour", action: { self.showDialogue(ofType: .skippedTour) })
        let buttons = [button1, button2]
        
        // Size
        let height: CGFloat? = 580
        let width: CGFloat? = 300
        let setSize = true
        
        // Payload
        let payload = DialoguePayload(type: type, title: title, messages: messages, buttons: buttons, width: width, height: height, setSize: setSize)
        
        Utilities.presentDialogue(self, payload: payload)
    }
    
    func showAfterTourDialogue(skippedTour: Bool) {
        // Parameters
        let type = DialogueType.afterTour
        
        // Title
        let title = "That's all!"

        // Messages
        let message1 = "You win if you've filled the frame with royal cards, and you lose if you can't place or remove more cards."
        let message2 = "Set the difficulty and find tips and FAQ in Settings menu."
        let message3 = "Enjoy playing Royal Frame!"
        let messages = [message1, message2, message3]
        
        // Buttons
        let button1 = DialogueButton(text: "Start playing", action: nil)
        let button2 = DialogueButton(text: skippedTour ? "Take tour" : "Redo tour", action: { self.coachMarksController.start(in: .window(over: self)) })
        let buttons = [button1, button2]
        
        // Size
        let height: CGFloat? = 400
        let width: CGFloat? = 300
        let setSize = true

        // Payload
        let payload = DialoguePayload(type: type, title: title, messages: messages, buttons: buttons, width: width, height: height, setSize: setSize)
        
        Utilities.presentDialogue(self, payload: payload)
    }
}

extension Utilities {
    static func viewControllerIdentifier(for dialogueType: DialogueType) -> String {
        switch dialogueType {
        case .onboarding:
            return "onboarding"
        case .afterTour, .skippedTour:
            return "onboarding2"
        case .info:
            return "info"
        default:
            return "alert"
        }
    }
    
    public static func presentDialogue(_ presentingViewController: UIViewController, payload: DialoguePayload) {
        let dialogueType = payload.type!
        
        let myStoryboard = UIStoryboard(name: "Dialogues", bundle: nil)
//        let dialogue = myStoryboard.instantiateViewController(withIdentifier: dialogueType.rawValue) as! DialogueVC
        let identifier = viewControllerIdentifier(for: dialogueType)
        let dialogue = myStoryboard.instantiateViewController(withIdentifier: identifier) as! DialogueVC
        dialogue.modalPresentationStyle = .overCurrentContext
        dialogue.modalTransitionStyle = .crossDissolve
        dialogue.payload = payload
        
        dialogue.view.backgroundColor = .frameBackgroundOverlay
        
        presentingViewController.present(dialogue, animated: true, completion: nil)

    }
}

extension SettingsVC {
    func showSettingChangeDialogue(for settingName: String, currentValue: Any) {
        // Parameters
        let type: DialogueType = .settingChange
        
        // Title
        let title = settingName
        
        // Messages
        let message1 = "This setting for the current game has already been set on \(currentValue)."
        let message2 = "This change will be active in the next game."
        let messages = [message1, message2]
        
        // Buttons
        let button1 = DialogueButton(text: "Got it")
        let button2 = DialogueButton(text: "New game") {
            if let presenter = self.presentingViewController as? GameVC {
                presenter.addStats(because: .newGameWithNewDifficulty)
                
                // Using a delay because of a next cards animation location bug
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                    presenter.startNewGame()
                }
            }
            self.dismiss(animated: true)
        }
        
        let buttons = [button1, button2]
        
        // Size
        let height: CGFloat? = nil
        let width: CGFloat? = nil
        let setSize = false
        
        // Payload
        let payload = DialoguePayload(type: type, title: title, messages: messages, buttons: buttons, width: width, height: height, setSize: setSize)
        
        Utilities.presentDialogue(self, payload: payload)
    }
    
    func showInfoDialogue(withTitle title: String, andMessage text: String) {
        // Parameters
        let type: DialogueType = .info
        let isDifficulty = title.lowercased().contains("difficulty")
        
        // Messages
        let message1 = text
        let message2 = ""
        let messages = [message1, message2]
        
        // Buttons
        let button1 = DialogueButton(text: "OK")
        let buttons = [button1, button1]
        
        // Size
        let height: CGFloat? = isDifficulty ? 300 : nil
        let width: CGFloat? = nil
        let setSize = isDifficulty ? true : false
        
        // Payload
        let payload = DialoguePayload(type: type, title: title, messages: messages, buttons: buttons, width: width, height: height, setSize: setSize)
        Utilities.presentDialogue(self, payload: payload)
    }
}
