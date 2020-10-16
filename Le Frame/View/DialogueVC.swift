//
//  DialogueVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2020.
//  Copyright © 2020 Saar Botzer. All rights reserved.
//

import UIKit

enum DialogueType: String {
    case gameOver, gameWon, restart, info, settingChange, onboarding, afterTour, skippedTour
    case gameOverRestart, gameWonRestart
}

struct DialogueButton {
    var text: String!
    var action: (() -> Void)? = nil
}

struct DialoguePayload {
    var type: DialogueType!
    var title: String!
    var messages: [String]!
    var buttons: [DialogueButton]!
    var width: CGFloat?
    var height: CGFloat?
    var setSize: Bool = false
}


class DialogueVC: UIViewController {

    var payload: DialoguePayload!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var logoImageView: UIImageView?
    @IBOutlet weak var frameImageView: UIImageView?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var message1Label: UILabel!
    @IBOutlet weak var message2Label: UILabel?
    @IBOutlet weak var message3Label: UILabel?
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    // Constraints
    @IBOutlet weak var alertViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    
    
    private let defaultHeight: CGFloat = 360
    private let defaultWidth: CGFloat = 240
        
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.roundCorners(.allCorners, radius: 20)
        
        configByPayload()
        configureLabels()
        
        configureViews()
        configureSize()
    }
    
    func configureSize() {
        
        var defaultWidthActive: Bool = false
        var defaultHeightActive: Bool = true
        var widthMultiplier: CGFloat = 0.8
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
    
    @IBAction func button1Tapped(_ sender: Any) {
        buttonTapped(index: 0)
    }
    
    @IBAction func button2Tapped(_ sender: Any) {
        buttonTapped(index: 1)
    }
    
    func buttonTapped(index: Int) {
        presentingViewController?.dismiss(animated: true, completion: nil)
        payload.buttons[index].action?()
    }
    
    func configureLabels() {
        let labels = [titleLabel, message1Label, message2Label, message3Label, button1.titleLabel, button2.titleLabel]
        
        for label in labels {
            if let label = label {
                label.adjustsFontSizeToFitWidth = true
            }
        }
        
    }
    
    func configureButtons() {
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
    
    func configByPayload() {
        
        // TODO: Handle one/two buttons
        button1.setTitle(payload.buttons[0].text, for: .normal)
        button2.setTitle(payload.buttons[1].text, for: .normal)
        
        configureButtons()
        
        if payload.messages.count > 0 {
            message1Label.text = payload.messages[0]
        }
        if payload.messages.count > 1 {
            message2Label?.text = payload.messages[1]
        }
        if payload.messages.count > 2 {
            message3Label?.text = payload.messages[2]
        }

        
        var finalHeight: CGFloat = defaultHeight
        var finalWidth: CGFloat = defaultWidth
        
        /*
//        let setSize = payload.setSize
        let setSize = false
        
        if setSize {
            if let height = payload.height {
                finalHeight = height
            }
            if let width = payload.width {
                finalWidth = width
            }
            
            for constraint in alertView.constraints {
                guard constraint.firstAttribute == .height || constraint.firstAttribute == .width else { continue }
                constraint.isActive = false
            }
            
//            alertView.heightAnchor.constraint(equalToConstant: finalHeight).isActive = true
//            alertView.widthAnchor.constraint(equalToConstant: finalWidth).isActive = true
        }
        */
                
        titleLabel.text = payload.title
        
    }

}
