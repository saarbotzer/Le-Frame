//
//  DialogueVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2020.
//  Copyright © 2020 Saar Botzer. All rights reserved.
//

import UIKit

class DialogueVC: UIViewController {

    // MARK: Parameters and IBOutlets
    var payload: DialoguePayload!
    
    // AlertView
    @IBOutlet weak var alertView: UIView!
    
    // Images
    @IBOutlet weak var logoImageView: UIImageView?
    @IBOutlet weak var frameImageView: UIImageView?
    
    // Labels
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var message1Label: UILabel!
    @IBOutlet weak var message2Label: UILabel?
    @IBOutlet weak var message3Label: UILabel?
    
    // Buttons
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    // Constraints
    @IBOutlet weak var alertViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.roundCorners(.allCorners, radius: 20)
        
        configureByPayload()
    }
    
    // MARK: Buttons Functions
    
    @IBAction func button1Tapped(_ sender: Any) {
        buttonTapped(index: 0)
    }
    
    @IBAction func button2Tapped(_ sender: Any) {
        buttonTapped(index: 1)
    }
    
    /// Called when a button was tapped
    /// - Parameter index: The button's index
    func buttonTapped(index: Int) {
        presentingViewController?.dismiss(animated: true, completion: nil)
        payload.buttons[index].action?()
    }
    
    // MARK: Configuration Functions
    
    /// Configures DialogueVC based on received payload
    func configureByPayload() {
        configureSize()
        configureViews()
        configureLabels()
        configureButtons()
    }
    
    /// Determines the size of the dialogue
    func configureSize() {
        
        let defaultWidthActive: Bool = false
        var defaultHeightActive: Bool = true
        let widthMultiplier: CGFloat = 0.8
        var heightMultiplier: CGFloat = 0.4
        
        switch payload.type {
        case .onboarding:
            break
        case .afterTour, .skippedTour:
            break
        case .restart, .settingChange, .gameOverRestart, .gameWonRestart:
            defaultHeightActive = false
            heightMultiplier = 0.275

        case .gameWon, .gameOver:
            defaultHeightActive = false
            heightMultiplier = 0.325
            
        default:
            break
        }
        
        // Width
        alertViewWidthConstraint.isActive = defaultWidthActive
        alertView.widthAnchor.constraint(equalToConstant: view.frame.width * widthMultiplier).isActive = !defaultWidthActive

        // Height
        alertViewHeightConstraint.isActive = defaultHeightActive
        alertView.heightAnchor.constraint(equalToConstant: view.frame.height * heightMultiplier).isActive = !defaultHeightActive

    }
    
    /// Hides and shows views
    func configureViews() {
        switch payload.type {
        case .onboarding:
            logoImageView?.isHidden = false
            frameImageView?.isHidden = false
        case .afterTour, .skippedTour:
            logoImageView?.isHidden = false
            frameImageView?.isHidden = true
        default:
            logoImageView?.isHidden = true
            frameImageView?.isHidden = true
        }
    }
    
    /// Changes the text for labels and formats them
    func configureLabels() {
        // Adjust Font Size
        let labels = [titleLabel, message1Label, message2Label, message3Label, button1.titleLabel, button2.titleLabel]
        
        for label in labels {
            if let label = label {
                label.adjustsFontSizeToFitWidth = true
            }
        }
        
        // Title Label
        titleLabel.text = payload.title

        // Messages Labels
        if payload.messages.count > 0 {
            message1Label.text = payload.messages[0]
        }
        if payload.messages.count > 1 {
            message2Label?.text = payload.messages[1]
        }
        if payload.messages.count > 2 {
            message3Label?.text = payload.messages[2]
        }
        
        
    }
    
    /// Formats the buttons UI and labels
    func configureButtons() {
        
        // TODO: Handle one/two buttons
        // Buttons Labels
        button1.setTitle(payload.buttons[0].text, for: .normal)
        button2.setTitle(payload.buttons[1].text, for: .normal)
        
        // Buttons UI
        switch payload.type {
        case .onboarding, .skippedTour, .afterTour, .gameOver, .gameOverRestart, .gameWon, .gameWonRestart, .info, .settingChange:
            
            let buttonPadding: CGFloat = 10
            button1.contentEdgeInsets = UIEdgeInsets(top: buttonPadding, left: buttonPadding, bottom: buttonPadding, right: buttonPadding)
            button1.roundCorners(.allCorners, radius: button1.bounds.size.height / 2)
            button1.clipsToBounds = true
            button1.setTitleColor(.black, for: .normal)
            button1.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
//            button1.backgroundColor = .frameGold
            let backgroundImage = #imageLiteral(resourceName: "alert-button-background")
            button1.setBackgroundImage(backgroundImage, for: .normal)
            button1.imageView?.contentMode = .scaleAspectFit
                        
//            button1.widthAnchor.constraint(equalToConstant: 100).isActive = true

        case .restart:
            if let buttonsStackView = button1.superview as? UIStackView {
                buttonsStackView.distribution = .fillEqually
            }
            
            button1.backgroundColor = .clear
            button1.setTitleColor(.lightGray, for: .normal)
            button2.setTitleColor(.white, for: .normal)
            button2.titleLabel?.font = button1.titleLabel?.font
            
        default:
            break
        }
    }

}


/// The data that dialogues receive
struct DialoguePayload {
    var type: DialogueType!
    var title: String!
    var messages: [String]!
    var buttons: [DialogueButton]!
}

enum DialogueType: String {
    /// Called when the user lost
    case gameOver
    
    /// Called when the user won
    case gameWon
    
    /// Called when tapped the restart button during a game
    case restart
    
    /// Called when tapped the info button in settings
    case info
    
    /// Called when a setting was changed and the user need to know about the chang
    case settingChange
    
    /// Called on first play, before the tour
    case onboarding
    
    /// Called on first play, after the user finished the entire tour
    case afterTour
    
    /// Called on first play, if ther user skipped the tour
    case skippedTour
    
    /// Called when tapping the restart button after the game was lost
    case gameOverRestart
    
    /// Called when tapping the restart button after the game was won
    case gameWonRestart
}

struct DialogueButton {
    var text: String!
    var action: (() -> Void)? = nil
}
